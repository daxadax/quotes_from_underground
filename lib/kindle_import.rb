require 'kindleclippings'

ImportResult = Struct.new(:error, :possible_duplicates, :added_quotes, keyword_init: true) do
  def self.fail(message)
    new(error: message, possible_duplicates: [], added_quotes: [])
  end

  def self.ok(added:, duplicates: [])
    new(error: nil, possible_duplicates: duplicates, added_quotes: added)
  end
end

module KindleImport
  module_function

  def call(user_uid:, file:)
    return ImportResult.fail('Not a valid user uid') if user_uid.to_s.empty?
    return ImportResult.fail('Not a valid kindle clippings file') unless file.to_s.start_with?('==')

    user_uid = user_uid.to_s
    added = []
    duplicates = []

    parse_clippings(file).each do |clipping|
      next if clipping.type == :Bookmark

      quote = build_quote(clipping, user_uid)
      next unless quote

      AutotagQuote.call(quote)

      match = find_duplicate(quote)
      if match
        duplicates << [quote, match]
        next
      end

      result = Quote.create_for(
        user_uid: user_uid,
        attrs: {
          content: quote.content,
          publication_uid: quote.publication_uid,
          page_number: quote.page_number,
          tags: quote.tags || []
        }
      )
      next if result.error

      added << Quote.eager(:publication)[result.uid]
    end

    ImportResult.ok(added: added.compact, duplicates: duplicates)
  end

  def parse_clippings(file_content)
    KindleClippings::Parser.new.parse(file_content)
  end

  def build_quote(clipping, user_uid)
    return if clipping.content.to_s.empty?

    publication = find_or_create_publication(clipping.author, clipping.book_title, user_uid)
    return unless publication

    Quote.new(
      content: clipping.content,
      publication_uid: publication.publication_uid,
      page_number: clipping.page,
      tags: [],
      added_by: user_uid
    ).tap { |quote| quote.associations[:publication] = publication }
  end

  def find_or_create_publication(author, title, user_uid)
    existing = Publication.where(author: author, title: title).first
    return existing if existing

    result = Publication.create_for(
      user_uid: user_uid,
      attrs: {
        author: author,
        title: title,
        publisher: 'kindle import',
        year: 0
      }
    )
    return nil if result.error

    Publication[result.uid]
  end

  def find_duplicate(quote)
    Quote.eager(:publication)
      .join(:publications, publication_uid: :publication_uid)
      .where(
        Sequel[:publications][:author] => quote.author,
        Sequel[:publications][:title] => quote.title
      )
      .select_all(:quotes)
      .all
      .find { |persisted| content_diff_ratio(persisted.content, quote.content) <= 0.2 }
  end

  def content_diff_ratio(original, candidate)
    original_words = original.to_s.split
    return 1.0 if original_words.empty?

    candidate_words = candidate.to_s.split
    (original_words - candidate_words).size / original_words.size.to_f
  end
end

module AutotagQuote
  module_function

  def call(quote)
    quote.tags ||= []
    all_tags.each do |tag|
      next if quote.tags.include?(tag)
      next unless quote.content.match?(/\b#{Regexp.escape(tag)}\b/i)

      quote.tags << tag
    end
    quote
  end

  def all_tags
    DB.fetch('SELECT unnest(tags) AS tag FROM quotes').map { |row| row[:tag] }.uniq
  end
end

if __FILE__ == $PROGRAM_NAME
  a = %w[one two three four]
  b = %w[one two three]
  ratio = KindleImport.content_diff_ratio(a.join(' '), b.join(' '))
  abort('content_diff_ratio broken') unless ratio <= 0.2
end

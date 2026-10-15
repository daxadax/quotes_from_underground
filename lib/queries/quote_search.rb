module Queries
  class QuoteSearch
    Result = Struct.new(:query, :tags, :quotes, keyword_init: true)
    TAG_PATTERN = /\[.*?\]/.freeze

    def self.call(raw_query)
      new(raw_query).call
    end

    def initialize(raw_query)
      @raw = raw_query.to_s
      @tags = filter_tags
      @text = strip_tags_from_text
    end

    def call
      return empty_result if @text.empty? && @tags.empty?

      dataset = base_dataset
      dataset = apply_tag_filter(dataset) if @tags.any?
      dataset = apply_text_filter(dataset) if @text.match?(/\S/)

      Result.new(
        query: @text,
        tags: display_tags,
        quotes: dataset.order(Sequel[:quotes][:uid]).all
      )
    end

    private

    def empty_result
      Result.new(query: @text, tags: display_tags, quotes: [])
    end

    def display_tags
      @raw.scan(TAG_PATTERN).map { |bracket| bracket.match(/\[(.*)\]/)[1] }
    end

    def filter_tags
      display_tags.map { |tag| tag.strip.downcase }.reject(&:empty?)
    end

    def strip_tags_from_text
      @raw.sub(/\[.*\]/, '').strip
    end

    def base_dataset
      Quote.eager(:publication).join(:publications, publication_uid: :publication_uid)
    end

    def apply_tag_filter(dataset)
      @tags.each do |tag|
        dataset = dataset.where(
          Sequel[:quotes][:uid] => DB[:quote_tags].where(tag: tag).select(:quote_uid)
        )
      end
      dataset
    end

    def apply_text_filter(dataset)
      pattern = Regexp.escape(@text)
      dataset.where(
        Sequel.|(
          Sequel.lit('publications.author ~* ?', pattern),
          Sequel.lit('publications.title ~* ?', pattern),
          Sequel.lit("quotes.content_tsv @@ plainto_tsquery('english', ?)", @text)
        )
      )
    end
  end
end

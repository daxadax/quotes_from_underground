class Quote < Sequel::Model
  set_primary_key :uid
  unrestrict_primary_key

  many_to_one :publication, key: :publication_uid, primary_key: :publication_uid
  many_to_one :adder, class: :User, key: :added_by

  plugin :validation_helpers

  def validate
    super
    validates_presence %i[content publication_uid added_by]
  end

  def before_save
    super
    normalize_content!
    normalize_tags!
    refresh_content_tsv!
  end

  def after_save
    super
    sync_quote_tags!
  end

  def author
    publication&.author
  end

  def title
    publication&.title
  end

  def publisher
    publication&.publisher
  end

  def year
    publication&.year
  end

  # quote_links table not wired in UI yet
  def links
    []
  end

  CREATE_ATTRS = %i[content publication_uid page_number tags].freeze
  UPDATE_ATTRS = CREATE_ATTRS

  def self.create_for(user_uid:, attrs:)
    return WriteResult.fail(:invalid_input) if user_uid.to_s.empty?

    data = attrs.slice(*CREATE_ATTRS)
    return WriteResult.fail(:invalid_input) unless new_quote_valid?(data)

    quote = create(
      added_by: user_uid,
      content: data[:content].to_s,
      publication_uid: data[:publication_uid].to_i,
      page_number: data[:page_number],
      tags: data[:tags] || []
    )
    WriteResult.ok(quote.uid)
  rescue Sequel::ValidationFailed, Sequel::ForeignKeyConstraintViolation
    WriteResult.fail(:invalid_input)
  end

  def update_by(owner_uid, attrs)
    return WriteResult.fail(:invalid_user) unless added_by == owner_uid
    return WriteResult.fail(:invalid_input) if attrs.values.any? { |value| value.to_s.empty? }

    data = attrs.slice(*UPDATE_ATTRS)
    update(data)
    WriteResult.ok(uid)
  rescue Sequel::ValidationFailed, Sequel::ForeignKeyConstraintViolation
    WriteResult.fail(:invalid_input)
  end

  def delete_by(owner_uid)
    return WriteResult.fail(:invalid_input) if owner_uid.to_s.empty?
    return WriteResult.fail(:invalid_user) unless added_by == owner_uid

    destroy
    WriteResult.ok
  end

  def self.new_quote_valid?(data)
    return false unless data.is_a?(Hash)

    content = data[:content]
    publication_uid = data[:publication_uid]
    return false if content.nil? || content.to_s.empty?
    return false if publication_uid.nil? || publication_uid.to_s.empty?

    true
  end
  private_class_method :new_quote_valid?

  private

  def normalize_tags!
    return unless tags

    self.tags = tags.map { |tag| tag.to_s.strip.downcase }.reject(&:empty?)
  end

  def normalize_content!
    return if content.nil?

    self.content = ContentNormalizer.normalize(content)
  end

  def refresh_content_tsv!
    return if content.nil?

    self.content_tsv = DB.get(Sequel.lit("to_tsvector('english', ?)", content))
  end

  def sync_quote_tags!
    DB[:quote_tags].where(quote_uid: uid).delete
    Array(tags).each do |tag|
      DB[:quote_tags].insert(quote_uid: uid, tag: tag)
    end
  end
end

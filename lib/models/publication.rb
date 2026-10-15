class Publication < Sequel::Model
  set_primary_key :publication_uid
  unrestrict_primary_key

  many_to_one :adder, class: :User, key: :added_by
  one_to_many :quotes, key: :publication_uid, primary_key: :publication_uid

  plugin :validation_helpers

  def validate
    super
    validates_presence %i[author title year added_by]
  end

  # views and routes still say publication.uid in places
  def uid
    publication_uid
  end

  CREATE_ATTRS = %i[author title publisher year].freeze
  UPDATE_ATTRS = CREATE_ATTRS

  def self.create_for(user_uid:, attrs:)
    return WriteResult.fail(:invalid_input) if user_uid.to_s.empty?

    data = attrs.slice(*CREATE_ATTRS)
    return WriteResult.fail(:invalid_input) unless new_publication_valid?(data)

    publication = create(
      added_by: user_uid,
      author: data[:author].to_s,
      title: data[:title].to_s,
      publisher: data[:publisher].to_s,
      year: data[:year].to_i
    )
    WriteResult.ok(publication.uid)
  rescue Sequel::ValidationFailed
    WriteResult.fail(:invalid_input)
  end

  def update_by(owner_uid, attrs)
    return WriteResult.fail(:invalid_user) unless added_by == owner_uid

    data = attrs.slice(*UPDATE_ATTRS)
    return WriteResult.fail(:invalid_input) if data.empty?

    data[:year] = data[:year].to_i if data.key?(:year)
    update(data)
    WriteResult.ok(uid)
  rescue Sequel::ValidationFailed
    WriteResult.fail(:invalid_input)
  end

  def delete_by(owner_uid)
    return WriteResult.fail(:invalid_input) if owner_uid.to_s.empty?
    return WriteResult.fail(:invalid_user) unless added_by == owner_uid

    destroy
    WriteResult.ok
  end

  def self.new_publication_valid?(data)
    return false unless data.is_a?(Hash)

    %i[author title year].all? do |key|
      value = data[key]
      !value.nil? && !value.to_s.empty?
    end
  end
  private_class_method :new_publication_valid?
end

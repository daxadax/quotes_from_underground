require 'json'

module Support
  module FactoryHelpers
    def create_quotes_with_tags(size, used_tags, options = {})
      size.times do |index|
        options_for_quote = {
          :content => "A quote about #{used_tags[index]}",
          :tags => [used_tags[index]]
        }.merge(options)

        create_quote(options_for_quote)
      end
    end

    def create_quote(options = {})
      options[:publication] = create_publication(options)
      quote = build_quote(options)
      uid = quotes_gateway.add quote

      quotes_gateway.get uid
    end

    def build_quote(options = {})
      added_by = options[:added_by] || 23
      content = options[:content] || 'Content'
      publication = options[:publication] || build_publication(1)

      Quotes::Entities::Quote.new(added_by, content, publication, options)
    end

    def build_serialized_quote(options = {})
      added_by = options[:added_by] || 23
      content = options[:content] || 'Content'
      publication_uid = options[:publication_uid] || create_publication.uid

      {
        :uid => options[:uid] || nil,
        :added_by => added_by,
        :content => content,
        :publication_uid => publication_uid,
        :page_number => options[:page_number] || nil,
        :tags => build_tags(options),
        :links => build_links(options)
      }
    end

    def create_publication(options = {})
      publication = build_publication(nil, options)
      uid = publications_gateway.add publication

      publications_gateway.get uid
    end

    def build_publication(uid, options = {})
      added_by = options[:added_by] || 23
      author = options[:author] || 'Author'
      title = options[:title] || 'Title'
      publisher = options[:publisher] || 'Publisher'
      year = options[:year] || 1963
      uid = uid

      Quotes::Entities::Publication.new(
        added_by, author, title, publisher, year, uid
      )
    end

    def build_serialized_publication(options = {})
      {
        :publication_uid => options[:uid] || nil,
        :publication_added_by => options[:added_by] || 23,
        :author => 'author',
        :title => options[:title] || 'title',
        :publisher => 'publisher',
        :year => 1999
      }
    end

    def create_user(options = {})
      user = build_user(options)
      gateway = Users::Gateways::UserGateway.new

      uid = gateway.add user
      gateway.get uid
    end

    def build_user(options = {})
      nickname = options[:nickname] || 'nickname'
      email = options[:email] || 'email'
      auth_key = options[:auth_key] || 'auth_key'

      Users::Entities::User.new(
        nickname, email, auth_key, options
      )
    end

    def build_serialized_user(options = {})
      {
        :uid => options[:uid],
        :nickname => options[:nickname] ||'nickname',
        :email => options[:email] ||'email',
        :auth_key => options[:auth_key] ||'auth_key',
        :favorites => build_favorites(options),
        :added_quotes => build_added_quotes(options),
        :added_publications => build_added_publications(options),
        :terms => false
      }
    end

    private

    def build_favorites(options)
      favorites = options[:favorities] || [23, 999]

      return dump(favorites) unless options[:no_json]
      favorites
    end

    def build_added_publications(options)
        added = options[:added_publications] || []

        return dump(added) unless options[:no_json]
        added
    end

    def build_added_quotes(options)
      added = options[:added_quotes] || []

      return dump(added) unless options[:no_json]
      added
    end

    def build_tags(options)
      tags = options[:tags] || []

      return dump(tags) unless options[:no_json]
      tags
    end

    def build_links(options)
      links = options[:links] || []

      return dump(links) unless options[:no_json]
      links
    end

    def dump(obj)
      JSON.dump(obj)
    end
  end
end

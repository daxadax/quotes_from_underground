module Quotes
  module Gateways
    class QuotesGateway < Gateway

      def initialize(backend = nil)
        @backend = backend || backend_for_quotes
        @marshal = QuoteMarshal
      end

      def add(quote)
        ensure_valid!(quote)

        @backend.insert(serialized(quote))
      end

      def get(uid)
        deserialize(@backend.get(uid))
      end

      def update(quote)
        ensure_persisted!(quote.uid, 'update', 'quote')

        @backend.update(serialized(quote))
      end

      def all
        @backend.all.map do |quote|
          deserialize(quote)
        end
      end

      def delete(uid)
        ensure_persisted!(uid, 'delete', 'quote')

        @backend.delete(uid)
      end

      private

      def marshal
        @marshal
      end

      class QuoteMarshal

        def self.dump(quote)
          tags = quote.tags.map(&:downcase)
          {
            :uid => quote.uid,
            :added_by => quote.added_by,
            :content => quote.content,
            :publication_uid => quote.publication_uid,
            :page_number => quote.page_number,
            :tags => JSON.dump(tags),
            :links => JSON.dump(quote.links)
          }
        end

        def self.load(quote)
          return nil unless quote

          added_by = quote[:added_by]
          content = quote[:content]
          publication = build_publication(quote)
          options = {
            :uid => quote[:uid],
            :page_number => quote[:page_number],
            :tags => JSON.parse(quote[:tags]),
            :links => JSON.parse(quote[:links])
          }

          Entities::Quote.new(added_by, content, publication, options)
        end

        def self.build_publication(quote)
          added_by = quote[:publication_added_by]
          author = quote[:author]
          title = quote[:title]
          publisher = quote[:publisher]
          year = quote[:year]
          uid = quote[:publication_uid]

          Entities::Publication.new(added_by, author, title, publisher, year, uid)
        end

      end

    end
  end
end

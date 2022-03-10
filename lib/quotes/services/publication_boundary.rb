require 'bound'

module Quotes
  module Services
    class PublicationBoundary < Service

      Publication = Bound.required(
        :uid,
        :added_by,
        :author,
        :title,
        :publisher,
        :year
      )

      def for(publication)
        build_boundary(publication)
      end

      private

      def build_boundary(publication)
        Publication.new(
          :uid => publication.uid,
          :added_by => publication.added_by,
          :author => publication.author,
          :title => publication.title,
          :publisher => publication.publisher,
          :year => publication.year
        )
      end

    end
  end
end

require './lib/quotes/services/publication_boundary'

module Quotes
  module UseCases
    class GetPublications < UseCase
      Publication = Services::PublicationBoundary::Publication
      Result = Bound.required( :publications => [Publication] )

      def call
        Result.new(:publications => get_publications)
      end

      private

      def get_publications
        publications = publications_gateway.all.map do |publication|
          publication_boundary.for publication
        end

        publications.reverse
      end
    end
  end
end

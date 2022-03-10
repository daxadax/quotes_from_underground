require './lib/quotes/services/publication_boundary'

module Quotes
  module UseCases
    class GetPublication < UseCase
      Publication = Services::PublicationBoundary::Publication
      Result = Bound.required( :publication => Publication )

      def initialize(input)
        ensure_valid_input!(input[:uid])

        @uid = input[:uid]
      end

      def call
        Result.new(:publication => get_publication)
      end

      private

      def get_publication
        publication = publications_gateway.get(@uid)

        publication_boundary.for publication
      end
    end
  end
end

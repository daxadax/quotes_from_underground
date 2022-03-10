module Quotes
  module UseCases
    class UseCase
      include Support::ValidationHelpers

      def quotes_gateway
        @quotes_gateway ||= Gateways::QuotesGateway.new
      end

      def publications_gateway
        @publications_gateway ||= Gateways::PublicationsGateway.new
      end

      def quote_boundary
        @quote_boundary ||= Services::QuoteBoundary.new
      end

      def publication_boundary
        @publication_boundary ||= Services::PublicationBoundary.new
      end

      def ensure_valid_input!(uid)
        reason = "The given UID is invalid"

        unless uid.kind_of? Integer || uid.nil?
          raise_argument_error(reason, uid)
        end
      end

    end
  end
end

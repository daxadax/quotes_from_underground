module Persistence
  module Gateways
    class PublicationsGatewayBackend < Backend
      def initialize
        super
        @table = @database[:publications]
      end

      private

      def object_identifier
        :publication_uid
      end

      def table
        @table
      end
    end
  end
end

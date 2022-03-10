module Persistence
  module Gateways
    class QuotesGatewayBackend < Backend
      def initialize
        super
        @table = @database[:quotes]
      end

      def get(uid)
        table.join(:publications, :publication_uid => :publication_uid).first(:uid => uid)
      end

      def all
        table.join(:publications, :publication_uid => :publication_uid).all
      end

      private

      def table
        @table
      end
    end
  end
end

module Persistence
  module Gateways
    class UsersGatewayBackend < Backend
      def initialize
        super
        @table = @database[:users]
      end

      def fetch(nickname)
        table.first(:nickname => nickname)
      end

      private

      def table
        @table
      end
    end
  end
end

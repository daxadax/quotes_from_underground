module Quotes
  module Tasks
    class Task
      def gateway
        @gateway ||= Gateways::QuotesGateway.new
      end
    end
  end
end

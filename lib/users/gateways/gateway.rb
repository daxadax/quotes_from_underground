require 'json'

module Users
  module Gateways
    class Gateway
      include Support::ValidationHelpers

      def backend_for_users
        @users_gateway_backend ||= new_backend
      end

      private

      def new_backend
        ServiceFactory.new.users_backend
      end
    end
  end
end

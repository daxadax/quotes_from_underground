module Users
  module Services
    class Service

      def user_gateway
        @user_gateway ||= Gateways::UserGateway.new
      end

    end
  end
end
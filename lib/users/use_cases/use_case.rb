module Users
  module UseCases
    class UseCase
      include Support::ValidationHelpers

      def gateway
        @gateway ||= Gateways::UserGateway.new
      end

      def user_boundary
        @boundary ||= Services::UserBoundary.new
      end

    end
  end
end
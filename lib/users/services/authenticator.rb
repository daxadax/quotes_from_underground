module Users
  module Services
    class Authenticator < Service
      def initialize(gateway = nil)
        @gateway = gateway || user_gateway
      end

      def for(nickname, auth_key)
        user = find_user(nickname)

        return :user_not_found unless user
        return :auth_failure  unless BCrypt::Password.new(user.auth_key) == auth_key
        user.uid
      end

      private

      def find_user(nickname)
        gateway.fetch(nickname)
      end

      def gateway
        @gateway
      end
    end
  end
end

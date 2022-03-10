module Users
  module UseCases
    class AuthenticateUser < UseCase
      Result = Bound.required(
        :error,
        :uid
      )

      def initialize(input)
        ensure_valid_input!(input)

        @nickname = input[:nickname]
        @auth_key = input[:auth_key]
      end

      def call
        Result.new(:error => error, :uid => user_uid)
      end

      private

      def authenticate_user
        @authenticator ||= authenticator.for(nickname, auth_key)
      end

      def user_uid
        return nil if authenticate_user.kind_of?(Symbol)
        authenticate_user
      end

      def error
        return nil if authenticate_user.kind_of?(Integer)
        authenticate_user
      end

      def nickname
        @nickname
      end

      def auth_key
        @auth_key
      end

      def authenticator
        Users::Services::Authenticator.new
      end

      def ensure_valid_input!(input)
        input.each_pair do |key, value|
          reason = "#{key} is blank or missing"

          if value.nil? || value.empty?
            raise_argument_error(reason, value)
          end
        end
      end
    end
  end
end

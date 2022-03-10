require './lib/users/services/user_boundary'

module Users
  module UseCases
    class GetUser < UseCase

      User = Services::UserBoundary::User
      Result = Bound.required(:error, :user => User )

      def initialize(input)
        @uid = input[:uid]
      end

      def call
        Result.new(:error => error, :user => get_user)
      end

      private

      def error
        return :invalid_input unless valid?
        nil
      end

      def get_user
        return nil unless valid?
        user = gateway.get(uid)

        user_boundary.for user
      end

      def uid
        @uid
      end

      def valid?
        return false unless uid.kind_of? Integer
        return false if uid.nil?
        true
      end

    end
  end
end

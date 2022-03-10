require './lib/users/services/user_boundary'

module Users
  module UseCases
    class GetUsers < UseCase

      User     = Services::UserBoundary::User
      Result  = Bound.required( :users => [User] )

      def call
        Result.new(:users => get_users)
      end

      private

      def get_users
        gateway.all.map { |user| user_boundary.for user }
      end

    end
  end
end

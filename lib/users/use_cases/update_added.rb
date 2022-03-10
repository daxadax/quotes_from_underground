require 'bound'

module Users
  module UseCases
    class UpdateAdded < UseCase
      Result = Bound.new(:error)

      def initialize(input)
        @uid = input[:uid]
        @quote_uid = input[:quote_uid]
        @publication_uid = input[:publication_uid]
      end

      def call
        return failure :nothing_to_update if nothing_to_update?
        return failure :user_not_found unless user

        update_added
        Result.new(:error => nil)
      end

      private

      def update_added
        update_added_quotes
        update_added_publications
        gateway.update user
      end

      def nothing_to_update?
        quote_uid.nil? && publication_uid.nil?
      end

      def update_added_quotes
        return unless quote_uid

        user.update_added :quotes, quote_uid
      end

      def update_added_publications
        return unless publication_uid

        user.update_added :publications, publication_uid
      end

      def failure(error)
        Result.new(:error => error)
      end

      def user
        @user ||= gateway.get(uid)
      end

      def quote_uid
        @quote_uid
      end

      def publication_uid
        @publication_uid
      end

      def uid
        @uid
      end

    end
  end
end

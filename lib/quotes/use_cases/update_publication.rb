module Quotes
  module UseCases
    class UpdatePublication < UseCase

      Result = Bound.required(:error, :uid)

      def initialize(input)
        @user_uid = input[:user_uid]
        @uid = input[:uid]
        @updates = input[:updates]
      end

      def call
        publication = publications_gateway.get uid

        return failure(:publication_not_found) unless publication
        return failure(:invalid_user) unless user_uid == publication.added_by

        Result.new(:error => nil, :uid => update(publication))
      end

      private

      def failure(msg)
        Result.new(:error => msg, :uid => nil)
      end

      def update(publication)
        publication.update(updates)
        publications_gateway.update publication
      end

      def uid
        @uid
      end

      def updates
        @updates
      end

      def user_uid
        @user_uid
      end

    end
  end
end

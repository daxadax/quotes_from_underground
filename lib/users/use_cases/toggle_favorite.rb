require 'bound'

module Users
  module UseCases
    class ToggleFavorite < UseCase

      Result = Bound.new(:error)

      def initialize(input)
        ensure_valid_input!(input)

        @uid = input[:uid]
        @quote_uid = input[:quote_uid]
        @error = nil
      end

      def call
        user = gateway.get(uid)
        return failure(:user_not_found) unless user

        toggle_favorite
      end

      private

      def failure(error)
        Result.new(:error => error)
      end

      def toggle_favorite
        gateway.toggle_favorite uid, quote_uid
      end

      def error
          @error
      end

      def uid
        @uid
      end

      def quote_uid
        @quote_uid
      end

      def ensure_valid_input!(input)
        input.each_pair do |key, value|
          reason = "The given #{key} was blank or missing"

          raise_argument_error(reason, value) if value.nil?
        end
      end

    end
  end
end

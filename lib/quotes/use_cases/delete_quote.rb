module Quotes
  module UseCases
    class DeleteQuote < UseCase

      Result = Bound.required(:error)

      def initialize(input)
        @uid = input[:uid]
        @user_uid = input[:user_uid]
      end

      def call
        check_for_errors

        delete_quote unless error
        Result.new(:error => error)
      end

      private

      def error
        @error
      end

      def check_for_errors
        set_error(:invalid_input) if invalid_input?
        set_error(:invalid_user) if invalid_user?
      end

      def set_error(msg)
        @error = msg
      end

      def delete_quote
        quotes_gateway.delete(uid)
      end

      def invalid_input?
        [uid, user_uid].each do |required|
          return true if required.nil? || !required.kind_of?(Integer)
        end
        false
      end

      def invalid_user?
        return if invalid_input?

        quote = quotes_gateway.get(uid)
        return true unless user_uid == quote.added_by
        false
      end

      def uid
        @uid
      end

      def user_uid
        @user_uid
      end

    end
  end
end

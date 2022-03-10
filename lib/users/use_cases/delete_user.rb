module Users
  module UseCases
    class DeleteUser < UseCase

      def initialize(input)
        @uid = input[:uid]
      end

      def call
        gateway.delete(uid)
      end

      private

      def uid
        @uid
      end

    end
  end
end

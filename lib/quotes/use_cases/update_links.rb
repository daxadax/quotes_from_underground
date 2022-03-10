module Quotes
  module UseCases
    class UpdateLinks < UseCase

      def initialize(input)
        ensure_valid_input!(input[:first])
        ensure_valid_input!(input[:second])

        @quote_one = input[:first]
        @quote_two = input[:second]
      end

      def call
        Services::LinksUpdater.new.update(@quote_one, @quote_two)
      end

    end
  end
end
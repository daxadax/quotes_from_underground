require './lib/quotes/services/quote_boundary'

module Quotes
  module UseCases
    class GetQuote < UseCase
      Quote   = Services::QuoteBoundary::Quote
      Result  = Bound.required( :quote => Quote )

      def initialize(input)
        ensure_valid_input!(input[:uid])

        @uid = input[:uid]
      end

      def call
        Result.new(:quote => get_quote)
      end

      private

      def get_quote
        quote = quotes_gateway.get(@uid)

        quote_boundary.for quote
      end
    end
  end
end

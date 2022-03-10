module Quotes
  module UseCases
    class AutotagQuotes < UseCase
      Result  = Bound.new

      def call
        autotag_quotes
      end

      private

      def autotag_quotes
        quotes.each do |quote|
          autotag quote
          quotes_gateway.update quote
        end
      end

      def autotag(quote)
        Services::Autotag.new(quote, tags).run
      end

      def quotes
        @quotes ||= quotes_gateway.all
      end

      def tags
        @tags ||= quotes.flat_map(&:tags).uniq
      end

    end
  end
end

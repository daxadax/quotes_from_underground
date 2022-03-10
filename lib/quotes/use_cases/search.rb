require 'bound'

module Quotes
  module UseCases
    class Search < UseCase

      Quote   = Services::QuoteBoundary::Quote
      Result  = Bound.required(
        :query,
        :tags,
        :quotes => [Quote]
      )

      def initialize(input)
        @query = input[:query]
      end

      def call
        build_result(search_results)
      end

      private

      def build_result(quotes)
        Result.new(
          :quotes => build_boundaries_from(quotes),
          :query  => query,
          :tags   => tags
        )
      end

      def build_boundaries_from(quotes)
        quotes.map do |quote|
          quote_boundary.for(quote)
        end
      end

      def search_results
        searchable.inject([]) do |result, quote|
          build_search_result(result, quote)
          result
        end
      end

      def build_search_result(result, quote)
        [ quote.author, quote.title, quote.content].any? do |q|
          result << quote if q.match(/#{query}/i)
        end
      end

      def searchable
        return [] if blank_query && tags.empty?
        return quotes if tags.empty?
        quotes.select { |q| (q.tags & tags) == tags }
      end

      def tags
        @tags ||= @query.scan(/\[.*?\]/).map do |tag|
          tag.match(/\[(.*)\]/)[1]
        end
      end

      def blank_query
        query.nil? || query.empty?
      end

      def quotes
        @quotes ||= quotes_gateway.all
      end

      def query
        @query_without_tags ||= @query.sub(/\[.*\]/, '').strip
      end

    end
  end
end

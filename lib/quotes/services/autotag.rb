module Quotes
  module Services
    class Autotag < Service

      def initialize(quote, tags = nil)
        @quote = quote
        @tags = tags || fetch_tags
      end

      def run
        add_matching_tags
        quote
      end

      private

      def add_matching_tags
        tags.each do |tag|
          #test this!
          next if quote.tags.include?(tag)

          if quote.content =~ /\b(#{Regexp.quote(tag)}\b)/i
            quote.tags << tag
          end
        end
      end

      def quote
        @quote
      end

      def tags
        @tags
      end

      def fetch_tags
        gateway.all.flat_map(&:tags).uniq
      end

      def gateway
        @gateway ||= Gateways::QuotesGateway.new
      end

    end
  end
end

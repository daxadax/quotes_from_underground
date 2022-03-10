module Quotes
  module UseCases
    class CreateQuote < UseCase
      Result = Bound.required(:error, :uid)

      def initialize(input)
        @user_uid = input[:user_uid]
        @quote = input[:quote]
      end

      def call
        return Result.new(:error => :invalid_input, :uid => nil) unless valid?

        Result.new(:error => nil, :uid => build_quote_and_add_to_gateway)
      end

      private

      def build_quote_and_add_to_gateway
        quote = build_quote
        add_to_gateway quote
      end

      def build_quote
        added_by = user_uid
        content = quote.delete(:content)
        publication = publications_gateway.get(quote.delete(:publication_uid))
        options = quote

        Entities::Quote.new(added_by, content, publication, options)
      end

      def add_to_gateway(quote)
        quotes_gateway.add quote
      end

      def user_uid
        @user_uid
      end

      def quote
        @quote
      end

      def valid?
        return false unless user_uid.kind_of?(Integer)
        return false unless quote.kind_of?(Hash)

        %i[content publication_uid].each do |required|
          return false if quote[required].nil?
          return false if quote[required].to_s.empty?
        end

        true
      end

    end
  end
end

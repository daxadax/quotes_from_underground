module Quotes
  module UseCases
    class ImportFromKindle < UseCase
      Result  = Bound.required(:error, :possible_duplicates, :added_quotes)

      def initialize(input)
        validate input

        @user_uid = input[:user_uid]
        @file = input[:file]
        @added_quotes = []
      end

      def call
        import_unique_quotes

        Result.new(
          :error => error,
          :possible_duplicates => duplicates,
          :added_quotes => added_quotes
        )
      end

      private

      def import_unique_quotes
        quotes = parse file

        add_to_gateway quotes
      end

      def add_to_gateway(quotes)
        quotes.each do |quote|
          next if duplicate?(quote)
          uid = quotes_gateway.add(quote)
          added_quotes << quotes_gateway.get(uid)
        end
      end

      def duplicate?(new_quote)
        duplicate = quotes_gateway.all.detect do |persisted_quote|
          persisted_quote.author == new_quote.author &&
          persisted_quote.title == new_quote.title &&
          string_diff(persisted_quote, new_quote) <= 0.2
        end

        if duplicate
          duplicates << [new_quote, duplicate]
          return true
        end
        false
      end

      def string_diff(original, new_string)
        original = original.content.split(' ')
        new_string = new_string.content.split(' ')

        (original - new_string).size / original.size.to_f
      end

      def parse(file)
        result = Services::KindleImporter.new(user_uid, file).import
        result
      end

      def validate(input)
        validate_user_uid input[:user_uid]
        validate_file input[:file]
      end

      def validate_user_uid(user_uid)
        msg = "Not a valid user uid"
        @error = msg if user_uid.nil? || !user_uid.is_a?(Integer)
      end

      def validate_file(file)
        msg = "Not a valid kindle clippings file"
        @error = msg if file.nil? || !file.start_with?("==")
      end

      def added_quotes
        @added_quotes
      end

      def user_uid
        @user_uid
      end

      def file
        @file
      end

      def duplicates
        @duplicates ||= []
      end

      def error
        @error
      end

    end
  end
end

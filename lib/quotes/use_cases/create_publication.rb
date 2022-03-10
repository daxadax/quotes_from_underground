module Quotes
  module UseCases
    class CreatePublication < UseCase
      Result = Bound.required(:error, :uid)

      def initialize(input)
        @user_uid = input[:user_uid]
        @publication = input[:publication]
      end

      def call
        return Result.new(:error => :invalid_input, :uid => nil) unless valid?

        Result.new(:error => nil, :uid => build_publication_and_add_to_gateway)
      end

      private

      def build_publication_and_add_to_gateway
        publication = build_publication
        add_to_gateway publication
      end

      def build_publication
        added_by = user_uid
        author = publication[:author]
        title = publication[:title]
        publisher = publication[:publisher]
        year = publication[:year]

        Entities::Publication.new(added_by, author, title, publisher, year)
      end

      def add_to_gateway(publication)
        publications_gateway.add publication
      end

      def publication
        @publication
      end

      def user_uid
        @user_uid
      end

      def valid?
        return false unless publication.kind_of?(Hash)
        return false unless user_uid.kind_of?(Integer)

        %i[author title year].each do |required|
          return false if publication[required].nil?
          return false if publication[required].to_s.empty?
        end

        true
      end

    end
  end
end

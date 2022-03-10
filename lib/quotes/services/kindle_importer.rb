require 'kindleclippings'

module Quotes
  module Services
    class KindleImporter < Service

      def initialize(user_uid, input, autotagger = nil)
        validate(input)

        @user_uid = user_uid
        @input = input
        @autotagger = autotagger || Services::Autotag
      end

      def import
        clippings.map do |clipping|
          next if clipping.type == :Bookmark
          build_and_tag clipping
        end.compact
      end

      private

      def validate(input)
        reason  = "Input missing"

        raise_argument_error(reason, input) if input.nil? || input.empty?
      end

      def build_and_tag(clipping)
        quote = build_quote_from clipping

        return if quote.nil?
        autotag quote
      end

      def autotag(quote)
        autotagger.new(quote).run
      end

      def build_quote_from(clipping)
        return if clipping.content.empty?

        publication = find_or_create_publication(clipping.author, clipping.book_title)
        content = clipping.content
        options = { :page_number => clipping.page }

        Entities::Quote.new @user_uid, content, publication, options
      end

      def find_or_create_publication(author, title)
        existing_publication = publication_gateway.all.detect do |publication|
          publication.author == author && publication.title == title
        end

        if existing_publication
          return existing_publication
        else
          create_new_publication(author, title)
        end
      end

      def create_new_publication(author, title)
        p = Entities::Publication.new(@user_uid, author, title, 'kindle import', 0)
        uid = publication_gateway.add p
        publication_gateway.get uid
      end

      def clippings
        parse @input
      end

      def parse(file_content)
        parser = KindleClippings::Parser.new
        parser.parse file_content
      end

      def autotagger
        @autotagger
      end

      def publication_gateway
        @publication_gateway ||= Gateways::PublicationsGateway.new
      end

    end
  end
end

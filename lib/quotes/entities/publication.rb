module Quotes
  module Entities
    class Publication < Entity
      attr_accessor :author, :title, :publisher, :year
      attr_reader :added_by, :uid

      def initialize(added_by, author, title, publisher, year, uid = nil)
        validate!(added_by, author, title, publisher, year)

        @uid = uid
        @added_by = added_by
        @author = author
        @title = title
        @publisher = publisher
        @year = year
      end

      private

      def validate!(added_by, author, title, publisher, year)
        ['added_by', 'author', 'title', 'publisher', 'year'].each do |param_name|
          value   = eval(param_name)
          reason  = "#{param_name.capitalize} missing"

          raise_argument_error(reason, value) if value.nil? || value.to_s.empty?
        end
      end

    end
  end
end

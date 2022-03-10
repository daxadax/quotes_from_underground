module Quotes
  module Entities
    class Quote < Entity
      attr_accessor :content, :page_number, :tags
      attr_reader   :links, :uid, :added_by

      def initialize(added_by, content, publication, options = {})
        validate_input!(added_by, content)
        ensure_valid_publication!(publication)

        @uid = options[:uid] || nil
        @added_by = added_by
        @content = content
        @publication = publication
        @page_number = options[:page_number] || nil
        @tags = construct_tags(options[:tags])
        @links = options[:links] || []
      end

      def publication_uid
        publication.uid
      end

      def author
        publication.author
      end

      def title
        publication.title
      end

      def publisher
        publication.publisher
      end

      def year
        publication.year
      end

      def update_links(link)
        if @links.include?(link)
          @links.delete(link)
        else
          @links.push(link)
        end
      end

      private

      def publication
        @publication
      end

      def construct_tags(tags)
        return [] unless tags

        tags.reject(&:empty?)
      end

      def validate_input!(added_by, content)
        ['added_by', 'content'].each do |param_name|
          value   = eval(param_name)
          reason  = "#{param_name.capitalize} missing"

          raise_argument_error(reason, value) if value.nil? || value.to_s.empty?
        end
      end

      def ensure_valid_publication!(publication)
        unless publication.kind_of?(Quotes::Entities::Publication) && !publication.uid.nil?
          reason = "Quotes must be created with an existing publication"
          raise_argument_error(reason, publication)
        end
      end

    end
  end

end

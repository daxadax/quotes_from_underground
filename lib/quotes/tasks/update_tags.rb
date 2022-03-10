module Quotes
  module Tasks
    class UpdateTags < Task
      def run
        quotes.each do |quote|
          updated = update_tags quote
          gateway.update updated
        end
      end

      private

      def update_tags(quote)
        Services::Autotag.new(quote).run
      end

      def quotes
        gateway.all
      end
    end
  end
end

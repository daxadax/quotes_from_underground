module Quotes
  module Entities
    class Entity
      include Support::ValidationHelpers

      def update(updates)
        update_values(updates)
        self
      end

      private

      def update_values(updates)
        updates.each do |attribute, updated_value|
          self.instance_variable_set "@#{attribute}", updated_value
        end
      end

    end
  end
end

require 'bundler'
Bundler.setup

require './lib/persistence'
require 'json'

module Quotes
  module Gateways
    class Gateway
      include Support::ValidationHelpers

      def backend_for_quotes
        @quotes_gateway_backend ||= new_quotes_backend
      end

      def backend_for_publications
        @publications_gateway_backend ||= new_publications_backend
      end

      def serialized(object)
        marshal.dump(object)
      end

      def deserialize(object)
        marshal.load(object)
      end

      def ensure_valid!(object)
        type = self.class.name.split("::").last.gsub('sGateway', '')

        ensure_kind_of!(object, type)
        ensure_not_persisted!(object, type)
      end

      private

      def ensure_kind_of!(object, type)
        reason = "Only #{type} entities can be added"

        unless object.kind_of? Entities.const_get(type)
          raise_argument_error(reason, object)
        end
      end

      def ensure_persisted!(uid, action, type)
        reason = "You tried to #{action} a #{type}, but it doesn't exist"

        raise_argument_error(reason, 'None.  ID is nil') if uid.nil?
      end

      def ensure_not_persisted!(object, type)
        reason = "#{type}s can't be added twice. Use #update instead"

        raise_argument_error(reason, object) unless object.uid.nil?
      end

      def new_quotes_backend
        ServiceFactory.new.quotes_backend
      end

      def new_publications_backend
        ServiceFactory.new.publications_backend
      end

    end
  end
end

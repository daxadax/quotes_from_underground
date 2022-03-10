require 'pg'
require 'sequel'
require 'securerandom'

module Persistence
  module Gateways
    class Backend
      include Support::ValidationHelpers

      def initialize
        @database = DATABASE_CONNECTION
      end

      def insert(object)
        ensure_valid!(object)

        # TODO: after getting everything working,
        # need to change field to uuid and type to string
        # table.insert(object.merge(uuid: SecureRandom.uuid))

        table.insert(object.merge(object_identifier => next_id))
      end

      def get(uid)
        table.first(object_identifier => uid)
      end

      def update(object)
        ensure_persisted!(object)

        table.where(object_identifier => object[object_identifier]).update(object)
      end

      def all
        table.all
      end

      def delete(uid)
        table.where(object_identifier => uid).delete
      end

      private

      def object_identifier
        :uid
      end

      # TODO: remove this
      def next_id
        table.all.empty? ? 1 : table.order(object_identifier).last[object_identifier] + 1
      end

      def ensure_valid!(obj)
        ensure_hash!(obj)
        ensure_not_persisted!(obj)
      end

      def ensure_not_persisted!(obj)
        reason = "Objects can't be added twice. Use #update instead"

        raise_argument_error(reason, obj) unless obj[object_identifier].nil?
      end

      def ensure_persisted!(obj)
        reason = "Objects must exist to update them. Use #insert instead"

        raise_argument_error(reason, obj) if obj[object_identifier].nil?
      end

      def ensure_hash!(obj)
        reason = "Only Hashes can be inserted"

        unless obj.kind_of? Hash
          raise_argument_error(reason, obj)
        end
      end

      # def no_database_provided
      #   'Please provide the database url to connect to as `ENV[DATABASE_URL]`'
      # end

      # def no_database_exists
      #   sql = 'create database <name> '\
      #   'DEFAULT CHARACTER SET utf8 '\
      #   'DEFAULT COLLATE utf8_general_ci;'

      #   "No database exists.  To create one, adjust and execute the following:"\
      #   "\n\necho \"#{sql}\" | ???"
      # end
    end
  end
end

module Users
  module Entities
    class User < Entity
      attr_reader :uid,
        :nickname,
        :email,
        :auth_key,
        :favorites,
        :added_quotes,
        :added_publications,
        :last_login_time,
        :last_login_address,
        :login_count

      def initialize(nickname, email, auth_key, options = {})
        ensure_valid_input!(nickname, email, auth_key)

        @nickname = nickname
        @email = email
        @auth_key = auth_key
        @uid = options[:uid] || nil
        @favorites = options[:favorites] || []
        @added_quotes = options[:added_quotes] || []
        @added_publications = options[:added_publications] || []
        @terms = options[:terms] || false
        @last_login_time = options[:last_login_time] || nil
        @last_login_address = options[:last_login_address] || nil
        @login_count = options[:login_count] || 0
      end

      def update(updates)
        update_user_values(updates)
        self
      end

      def terms_accepted?
        @terms
      end

      # TODO: this is just confusing..
      def update_added(type, uid)
        added = eval("added_#{type}")

        if added.include?(uid)
          added.delete(uid)
        else
          added << uid
        end
      end

      private

      def update_user_values(updates)
        updates.each do |attribute, updated_value|
          self.instance_variable_set "@#{attribute}", updated_value
        end
      end

      def ensure_valid_input!(nickname, email, auth_key)
        msg = 'Missing required input'

        raise_argument_error(msg, :nickname) if nickname.nil? || nickname.empty?
        raise_argument_error(msg, :email) if email.nil? || email.empty?
        raise_argument_error(msg, :auth_key) if auth_key.nil? || auth_key.empty?
      end
    end
  end
end

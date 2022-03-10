require 'bound'

module Users
  module Services
    class UserBoundary < Service

      User = Bound.required(
        :uid,
        :nickname,
        :email,
        :favorites,
        :added_quotes,
        :added_publications,
        :terms_accepted,
        :last_login_time,
        :last_login_address,
        :login_count
      )

      def for(user)
        build_boundary(user)
      end

      private

      def build_boundary(user)
        User.new(
          :uid => user.uid,
          :nickname => user.nickname,
          :email => user.email,
          :favorites => user.favorites,
          :added_quotes => user.added_quotes,
          :added_publications => user.added_publications,
          :terms_accepted => user.terms_accepted?,
          :last_login_time => user.last_login_time,
          :last_login_address => user.last_login_address,
          :login_count => user.login_count
        )
      end

    end
  end
end

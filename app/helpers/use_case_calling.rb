# TODO: why is this a helper? why a module?
# TODO: use self.call(args)
# TODO: use "update_added" unless error
module Helpers
  module UseCaseCalling
    # SEARCH
    def build_search_results
      input = { query: params['search'] }
      Quotes::UseCases::Search.new(input).call
    end

    # PUBLICATIONS
    # TODO: rename to create
    def build_publication
      input = {
        user_uid: current_user_uid,
        publication: symbolize_keys(params)
      }

      result = Quotes::UseCases::CreatePublication.new(input).call
      update_added(current_user_uid, :publication, result.uid) unless result.error
      result
    end

    def get_publications
      result = Quotes::UseCases::GetPublications.new.call
      result.publications
    end

    def update_publication
      input = {
        user_uid: current_user_uid,
        uid: uid,
        updates: symbolize_keys(params)
      }

      Quotes::UseCases::UpdatePublication.new(input).call
    end

    def delete_publication
      input = {
        user_uid: current_user_uid,
        uid: uid
      }

      result = Quotes::UseCases::DeletePublication.new(input).call
      update_added(current_user_uid, :publication, uid) unless result.error
      result
    end

    # QUOTES
    # TODO: rename to create
    def build_quote
      # TODO: wtf is this
      if !params['publication_uid']
        result = build_publication
        return result if result.error
        params['publication_uid'] = result.uid
      else
        params['publication_uid'].to_i
      end

      params['tags'] = build_tags


      input = {
        user_uid: current_user_uid,
        quote: symbolize_keys(params)
      }

      result = Quotes::UseCases::CreateQuote.new(input).call
      update_added(current_user_uid, :quote, result.uid) unless result.error
      result
    end

    def get_quotes
      result = Quotes::UseCases::GetQuotes.new.call
      result.quotes
    end

    def update_quote
      quote = quote_by_uid(uid)
      params['tags'] = build_tags

      input = {
        user_uid: current_user.uid,
        uid: uid,
        updates: symbolize_keys(params)
      }

      Quotes::UseCases::UpdateQuote.new(input).call
    end

    def delete_quote
      input = {
        user_uid: current_user_uid,
        uid: uid
      }

      result = Quotes::UseCases::DeleteQuote.new(input).call
      update_added(current_user_uid, :quote, uid) unless result.error
      result
    end

    # USERS
    def create_user
      email = params[:email].empty? ? 'no email added' : params[:email]
      auth_key = params[:nickname] + params[:password]

      input = {
        :nickname => params[:nickname],
        :email => email,
        :auth_key => auth_key
      }

      Users::UseCases::CreateUser.new(input).call
    end

    def get_user(uid)
      result = Users::UseCases::GetUser.new(uid: uid).call
      result.user unless result.error
    end

    def authenticate_user
      auth_key = params[:nickname] + params[:password]
      input = {
        nickname: params[:nickname],
        auth_key: auth_key,
        login_data: {
          ip_address: request.ip
        }
      }

      result = Users::UseCases::AuthenticateUser.new(input).call

      # TODO: log failed login
      unless result.error
        input = {
          :uid => result.uid,
          :auth_key => input[:auth_key],
          :updates => {
            :last_login_address => input[:login_data][:ip_address],
            :last_login_time => Time.now.utc.to_i,
            :update_login_count => true
          }
        }
        Users::UseCases::UpdateUser.new(input).call
      end

      result
    end

    # OTHER
    def toggle_star(quote_uid)
      input = {
        uid: current_user_uid,
        quote_uid: quote_uid.to_i
      }

      Users::UseCases::ToggleFavorite.new(input).call
    end

    def import_from_kindle
      input = {
        user_uid: current_user_uid,
        file: File.read(params[:file][:tempfile])
      }

      Quotes::UseCases::ImportFromKindle.new(input).call
    end

    def autotag
      Quotes::UseCases::AutotagQuotes.new.call
    end

    private

    # TODO: naming..?
    # TODO: can this just be update user?
    def update_added(user_uid, type, object_uid)
      input = { :uid => user_uid }
      input[:quote_uid] = object_uid if type == :quote
      input[:publication_uid] = object_uid if type == :publication

      Users::UseCases::UpdateAdded.new(input).call
    end

    def symbolize_keys(hash)
      hash.inject({}) do |result, (key, value)|
        new_key = key.is_a?(String) ? key.to_sym : key
        new_value = value.is_a?(Hash) ? symbolize_keys(value) : value

        result[new_key] = new_value
        result
      end
    end

    def build_tags
      params['tags'].split(',').each(&:strip!)
    end
  end
end

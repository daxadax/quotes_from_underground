module Helpers
  module UseCaseCalling
    def build_search_results
      Queries::QuoteSearch.call(params['search'])
    end

    def build_publication
      Publication.create_for(
        user_uid: current_user_uid,
        attrs: symbolize_keys(params)
      )
    end

    def update_publication
      publication = Publication[uid]
      return WriteResult.fail(:publication_not_found) unless publication

      publication.update_by(current_user_uid, symbolize_keys(params))
    end

    def delete_publication
      publication = Publication[uid]
      return WriteResult.fail(:publication_not_found) unless publication

      publication.delete_by(current_user_uid)
    end

    def build_quote
      pub_uid = params['publication_uid'].to_s.strip
      if pub_uid.empty?
        result = build_publication
        return result if result.error

        params['publication_uid'] = result.uid
      else
        params['publication_uid'] = pub_uid
      end

      params['tags'] = build_tags

      Quote.create_for(
        user_uid: current_user_uid,
        attrs: symbolize_keys(params)
      )
    end

    def update_quote
      quote = quote_by_uid(uid)
      return WriteResult.fail(:quote_not_found) unless quote

      params['tags'] = build_tags

      quote.update_by(current_user.uid, symbolize_keys(params))
    end

    def delete_quote
      quote = quote_by_uid(uid)
      return WriteResult.fail(:quote_not_found) unless quote

      quote.delete_by(current_user_uid)
    end

    def create_user
      email = params[:email].empty? ? 'no email added' : params[:email]
      auth_key = params[:nickname] + params[:password]

      User.register(
        nickname: params[:nickname],
        email: email,
        auth_key: auth_key
      )
    end

    def get_user(uid)
      User[uid]
    end

    def authenticate_user
      outcome = User.authenticate(params[:nickname], params[:password])
      return WriteResult.fail(outcome) if outcome.is_a?(Symbol)

      outcome.record_login!(ip: request.ip)
      WriteResult.ok(outcome.uid)
    end

    def toggle_star(quote_uid)
      return unless current_user

      quote = Quote[quote_uid.to_i]
      return unless quote

      current_user.toggle_favorite!(quote)
    end

    def import_from_kindle
      KindleImport.call(
        user_uid: current_user_uid,
        file: File.read(params[:file][:tempfile])
      )
    end

    private

    def symbolize_keys(hash)
      hash.inject({}) do |result, (key, value)|
        new_key = key.is_a?(String) ? key.to_sym : key
        new_value = value.is_a?(Hash) ? symbolize_keys(value) : value

        result[new_key] = new_value
        result
      end
    end

    def build_tags
      params['tags'].to_s.split(',').map(&:strip).reject(&:empty?)
    end
  end
end

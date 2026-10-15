class User < Sequel::Model
  set_primary_key :uid

  one_to_many :quotes, key: :added_by, primary_key: :uid
  one_to_many :publications, key: :added_by, primary_key: :uid
  many_to_many :favorite_quotes,
    join_table: :favorites,
    left_key: :user_uid,
    right_key: :quote_uid,
    class: :Quote

  plugin :validation_helpers

  def validate
    super
    validates_presence %i[nickname email auth_key]
    validates_unique :nickname
  end

  def self.authenticate(nickname, raw_password)
    user = find(nickname: nickname)
    return :user_not_found unless user

    auth_key = nickname + raw_password
    return :auth_failure unless BCrypt::Password.new(user.auth_key) == auth_key

    user
  end

  def record_login!(ip:)
    update(
      last_login_address: ip,
      last_login_time: Time.now.to_i,
      login_count: (login_count || 0) + 1
    )
  end

  def favorites
    DB[:favorites].where(user_uid: uid).select_map(:quote_uid)
  end

  def favorited?(quote_uid)
    DB[:favorites].where(user_uid: uid, quote_uid: quote_uid).any?
  end

  def self.register(nickname:, email:, auth_key:)
    return WriteResult.fail(:invalid_input) if [nickname, email, auth_key].any? { |v| v.nil? || v.to_s.empty? }
    return WriteResult.fail(:duplicate_user) if where(nickname: nickname).any?

    user = create(
      nickname: nickname,
      email: email,
      auth_key: BCrypt::Password.create(auth_key)
    )
    WriteResult.ok(user.uid)
  rescue Sequel::ValidationFailed, Sequel::UniqueConstraintViolation
    WriteResult.fail(:duplicate_user)
  end

  def toggle_favorite!(quote)
    row = DB[:favorites].where(user_uid: uid, quote_uid: quote.uid)
    if row.delete.positive?
      false
    else
      DB[:favorites].insert(user_uid: uid, quote_uid: quote.uid)
      true
    end
  end
end

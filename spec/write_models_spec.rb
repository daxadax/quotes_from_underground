require 'minitest/autorun'

root = File.expand_path('..', __dir__)
unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'

  Dotenv.load(
    File.expand_path('.env', root),
    File.expand_path(".env.#{ENV['RACK_ENV']}", root)
  )
end

require File.join(root, 'lib/boot.rb')

describe 'model write paths' do
  before do
    skip 'DATABASE_URL not set' unless ENV['DATABASE_URL']
  end

  it 'rejects quote create without content' do
    owner = User.first
    pub = Publication.first
    skip 'need imported data' unless owner && pub

    result = Quote.create_for(
      user_uid: owner.uid,
      attrs: { publication_uid: pub.publication_uid, content: '' }
    )
    assert_equal :invalid_input, result.error
  end

  it 'rejects publication create without author' do
    owner = User.first
    skip 'need imported data' unless owner

    result = Publication.create_for(
      user_uid: owner.uid,
      attrs: { title: 'T', year: 2000 }
    )
    assert_equal :invalid_input, result.error
  end

  it 'assigns uid on register' do
    nick = "regtest_#{Process.pid}_#{Time.now.to_i}"
    result = User.register(nickname: nick, email: 'e@example.com', auth_key: "x#{nick}")
    assert_nil result.error, result.error
    assert_match(/\A[0-9a-f-]{36}\z/i, result.uid)
    User[result.uid]&.destroy
  end

  it 'rejects update by non-owner' do
    quote = Quote.first
    skip 'no quotes in database' unless quote

    other_uid = User.exclude(uid: quote.added_by).first&.uid
    skip 'need another user' unless other_uid

    result = quote.update_by(other_uid, content: 'nope')
    assert_equal :invalid_user, result.error
  end
end

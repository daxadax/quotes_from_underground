require 'minitest/autorun'
require 'securerandom'

root = File.expand_path('..', __dir__)
unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'

  Dotenv.load(
    File.expand_path('.env', root),
    File.expand_path(".env.#{ENV['RACK_ENV']}", root)
  )
end

require File.join(root, 'lib/boot.rb')

describe KindleImport do
  it 'rejects invalid clippings files' do
    result = KindleImport.call(user_uid: SecureRandom.uuid, file: 'nonsense')
    assert_equal 'Not a valid kindle clippings file', result.error
  end

  describe 'with database' do
    before do
      skip 'DATABASE_URL not set' unless ENV['DATABASE_URL']
    end

    it 'imports highlights from sample clippings' do
      user = User.first
      skip 'need imported user' unless user

      before = Quote.count
      token = SecureRandom.hex(6)
      clippings = File.read(File.join(__dir__, 'support/sample_kindle_clippings.txt'))
      clippings = clippings
        .gsub('Sample highlight.', "Sample highlight #{token}.")
        .gsub('Sample note.', "Sample note #{token}.")
        .gsub('non-duplicate sample highlight', "non-duplicate sample highlight #{token}")
      result = KindleImport.call(user_uid: user.uid, file: clippings)

      assert_nil result.error
      assert_operator result.added_quotes.size, :>, 0
      assert_operator Quote.count, :>, before
      assert result.added_quotes.all? { |q| q.is_a?(Quote) }
    end
  end
end

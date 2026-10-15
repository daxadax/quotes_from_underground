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

describe 'v2 models' do
  before do
    skip 'DATABASE_URL not set' unless ENV['DATABASE_URL']
    skip 'need production import (1 user, 1453 quotes)' unless User.count == 1 && Quote.count == 1453
  end

  it 'reads imported production data' do
    assert_equal 1, User.count
    assert_equal 1453, Quote.count
    assert_equal 93, Publication.count

    dax = User.find(nickname: 'dax')
    assert_equal 33, dax.favorite_quotes.count

    quote = Quote.eager(:publication).where(uid: 119).first
    assert quote.tags.include?('groups of i"s')
    assert_equal quote.publication.author, quote.author
  end
end

require 'minitest/autorun'

root = File.expand_path('../..', __dir__)
unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'

  Dotenv.load(
    File.expand_path('.env', root),
    File.expand_path(".env.#{ENV['RACK_ENV']}", root)
  )
end

require File.join(root, 'lib/boot.rb')

describe Queries::QuoteSearch do
  it 'parses bracket tags and greedy tag strip (legacy search behavior)' do
    result = Queries::QuoteSearch.call('[tag_0] [two tags] author 19')

    assert_equal ['tag_0', 'two tags'], result.tags
    assert_equal 'author 19', result.query
  end

  it 'keeps display tag casing while filtering downcased' do
    result = Queries::QuoteSearch.call('[TeSt]')

    assert_equal ['TeSt'], result.tags
  end

  describe 'with database' do
    before do
      skip 'DATABASE_URL not set' unless ENV['DATABASE_URL']
    end

    it 'returns no rows for blank query' do
      result = Queries::QuoteSearch.call('')

      assert_empty result.quotes
      assert_empty result.tags
      assert_equal '', result.query
    end

    it 'finds quotes by publication author substring' do
      sample = Quote.eager(:publication).first
      needle = sample.author.split.first

      result = Queries::QuoteSearch.call(needle)

      assert result.quotes.any?
      assert(result.quotes.all? { |q| [q.author, q.title, q.content].any? { |f| f =~ /#{Regexp.escape(needle)}/i } })
    end

    it 'filters by tag when bracket syntax is used' do
      tagged = Quote.where(Sequel.lit('cardinality(tags) > 0')).first
      skip 'no tagged quotes in database' unless tagged

      tag = tagged.tags.first
      result = Queries::QuoteSearch.call("[#{tag}]")

      assert result.quotes.any?
      assert(result.quotes.all? { |q| q.tags.include?(tag) })
      assert_equal [tag], result.tags
    end
  end
end

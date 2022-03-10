require 'spec_helper'

class AutotagQuotesSpec < UseCaseSpec
  let(:use_case) { Quotes::UseCases::AutotagQuotes.new }
  let(:sample_tags) do
    [
      'little piggies',
      'bramble',
      'powdered wigs',
      'entropy',
      'circus peanuts'
    ]
  end

  before do
    create_quotes_with_tags(5, sample_tags)
    content = '23 little piggies with powdered wigs went to the circus'
    @quote_one = create_quote :content => content
    content = 'Eris enjoys entropy'
    @quote_two = create_quote :content => content, :tags => ['23']
  end

  it 'updates tags for all quotes' do
    assert_empty quote_one.tags
    assert_equal ['23'], quote_two.tags

    use_case.call

    quote = quotes_gateway.get(quote_one.uid)
    assert_equal 3, quote.tags.size
    assert_includes quote.tags, '23'
    assert_includes quote.tags, 'little piggies'
    assert_includes quote.tags, 'powdered wigs'

    quote = quotes_gateway.get(quote_two.uid)
    assert_equal 2, quote.tags.size
    assert_includes quote.tags, '23'
    assert_includes quote.tags, 'entropy'
  end

  def quote_one
    @quote_one
  end

  def quote_two
    @quote_two
  end
end

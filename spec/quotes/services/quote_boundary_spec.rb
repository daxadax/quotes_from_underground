require 'spec_helper'

class QuoteBoundarySpec < ServiceSpec
  let(:options_for_quote) do
    {
      :page_number => 23,
      :tags => %w[some fake tag],
      :links => [24, 36]
    }
  end

  let(:quote) { create_quote(options_for_quote) }
  let(:boundary) { Quotes::Services::QuoteBoundary.new }
  let(:result) { boundary.for(quote) }

  it "grants access to uid" do
    assert_equal quote.uid, result.uid
  end

  it 'grants access to added_by' do
    assert_equal quote.added_by, result.added_by
  end

  it 'grants access to publication_uid' do
    assert_equal quote.publication_uid, result.publication_uid
  end

  it "grants access to content" do
    assert_equal quote.content, result.content
  end

  it "grants access to page_number" do
    assert_equal quote.page_number, result.page_number
  end

  it "grants access to tags" do
    assert_equal quote.tags, result.tags
  end

  it "grants access to links" do
    assert_equal quote.links, result.links
  end

  it "grants access to author" do
    assert_equal quote.author, result.author
  end

  it "grants access to title" do
    assert_equal quote.title, result.title
  end

  it "grants access to publisher" do
    assert_equal quote.publisher, result.publisher
  end

  it "grants access to year" do
    assert_equal quote.year, result.year
  end
end

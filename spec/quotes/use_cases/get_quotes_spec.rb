require 'spec_helper'

class GetQuotesSpec < UseCaseSpec
  let(:use_case)  { Quotes::UseCases::GetQuotes.new }

  describe "call" do
    let(:result)        { use_case.call }
    let(:first_result)  { result.quotes.first }

    describe "with no quotes in the db" do
      let(:quotes) { nil }

      it "returns an empty array" do
        assert_empty  result.quotes
      end
    end

    describe "with 50 quotes in the db" do
      before do
        50.times { create_quote }
      end

      it "retrieves all quotes from the backend sorted by most recent" do
        assert_equal 50, result.quotes.size
        assert_kind_of Quotes::Services::QuoteBoundary::Quote, first_result

        assert_equal 50, first_result.uid
        assert_equal 23, first_result.added_by
        assert_equal 'Content', first_result.content
        assert_equal 50, first_result.publication_uid
      end
    end
  end
end

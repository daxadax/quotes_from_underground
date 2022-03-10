require 'spec_helper'

class GetQuoteSpec < UseCaseSpec
  let(:quote)     { create_quote }
  let(:input)     { {:uid => quote.uid} }
  let(:use_case)  { Quotes::UseCases::GetQuote.new(input) }

  describe "call" do
    let(:result) { use_case.call }

    describe "with unexpected input" do
      let(:quote) { build_quote }

      it "fails" do
        assert_failure { result }
      end
    end

    it "retrieves the quote with the given quote_uid as a bound object" do
      assert_equal quote.uid, result.quote.uid
      assert_equal quote.content, result.quote.content
      assert_equal quote.publication_uid, result.quote.publication_uid
    end
  end
end

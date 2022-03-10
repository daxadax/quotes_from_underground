require 'spec_helper'

class UpdateLinksSpec < UseCaseSpec
  let(:quote_one) { create_quote }
  let(:quote_two) { create_quote }
  let(:input) do
    {
      :first  => quote_one.uid,
      :second => quote_two.uid
    }
  end
  let(:use_case)  { Quotes::UseCases::UpdateLinks.new(input) }

  describe "call" do
    let(:result_one)  { quotes_gateway.get(quote_one.uid) }
    let(:result_two)  { quotes_gateway.get(quote_two.uid) }

    describe "with unexpected input" do
      let(:quote_one) { build_quote }

      it "fails" do
        assert_failure { use_case.call }
      end
    end

    it "updates links for the given quotes" do
      assert_empty quote_one.links
      assert_empty quote_two.links

      use_case.call

      assert_includes result_one.links, quote_two.uid
      assert_includes result_two.links, quote_one.uid
    end
  end
end

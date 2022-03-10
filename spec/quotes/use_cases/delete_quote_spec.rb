require 'spec_helper'

class DeleteQuoteSpec < UseCaseSpec
  let(:input) do
    {
      :user_uid => user_uid,
      :uid => quote_uid
    }
  end
  let(:user_uid) { 23 }
  let(:use_case) { Quotes::UseCases::DeleteQuote.new(input) }

  describe "call" do
    before { create_quotes }
    let(:result) { use_case.call }

    describe "with unexpected input" do
      describe 'with invalid input' do
        let(:quote_uid) { 'not a valid quote uid' }

        it "fails" do
          assert_equal :invalid_input, result.error
          assert_all_quotes_present
        end
      end

      describe 'with wrong user_uid' do
        let(:quote_uid) { quotes_gateway.all.last.uid }
        let(:user_uid) { 24 }

        it 'fails' do
          assert_equal :invalid_user, result.error
          assert_all_quotes_present
        end
      end
    end

    describe "with expected input" do
      let(:quote_uid) { quotes_gateway.all.last.uid }

      it "deletes the quote with the given quote_uid" do
        assert_all_quotes_present

        assert_nil result.error

        assert_equal 4, quotes_gateway.all.count
        assert_nil quotes_gateway.get(quote_uid)
      end
    end
  end

  def assert_all_quotes_present
    assert_equal 5, quotes_gateway.all.count
  end

  def create_quotes
    5.times { create_quote }
  end
end

require 'spec_helper'

class CreateQuoteSpec < UseCaseSpec
  let(:quote) { build_serialized_quote(:no_json => true) }
  let(:input) do
    {
      :user_uid => 1,
      :quote => quote
    }
  end
  let(:use_case) { Quotes::UseCases::CreateQuote.new(input) }

  describe "call" do
    let(:result)        { use_case.call }
    let(:loaded_quote)  { quotes_gateway.get(result.uid) }

    describe "with unexpected input" do
      describe "with no quote" do
        before { input.delete(:quote) }

        it "fails" do
          assert_equal :invalid_input, result.error
          assert_nil result.uid
        end
      end

      describe 'with no user_uid' do
        before { input.delete(:user_uid) }

        it "fails" do
          assert_equal :invalid_input, result.error
          assert_nil result.uid
        end
      end

      describe "without content" do
        before { quote.delete(:content) }

        it "fails" do
          assert_equal :invalid_input, result.error
          assert_nil result.uid
        end
      end

      describe "without publication_uid" do
        before { quote.delete(:publication_uid) }

        it "fails" do
          assert_equal :invalid_input, result.error
          assert_nil result.uid
        end
      end
    end

    it "builds a new quote and saves it to the database" do
      assert_nil result.error

      assert_equal 1, loaded_quote.uid
      assert_equal 1, loaded_quote.added_by
      assert_equal 'Content', loaded_quote.content
      assert_equal 1, loaded_quote.publication_uid
      assert_equal 'Author', loaded_quote.author
      assert_equal 'Title', loaded_quote.title
      assert_equal 'Publisher', loaded_quote.publisher
      assert_equal 1963, loaded_quote.year
    end

    it "returns the uid of the newly created quote on success" do
      assert_nil result.error
      assert_equal 1, result.uid
    end
  end
end

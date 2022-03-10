require 'spec_helper'

class UpdateQuoteSpec < UseCaseSpec
  let(:uid) { 1 }
  let(:user_uid) { 23 }
  let(:content) { 'updated content' }
  let(:updates) do
    {
      :content => content
    }
  end
  let(:input) do
    {
      :user_uid => user_uid,
      :uid => uid,
      :updates => updates
    }
  end
  let(:use_case) { Quotes::UseCases::UpdateQuote.new(input) }

  describe "call" do
    before { create_quote :tags => %w[heres some tags] }
    let(:result) { use_case.call }
    let(:loaded_quote) { quotes_gateway.get(result.uid) }

    describe "with invalid input" do
      describe "with a non-existent quote" do
        let(:uid) { 99 }

        it "fails" do
          assert_equal :quote_not_found, result.error
          assert_nil result.uid
        end
      end

      describe 'with empty strings for required fields' do
        let(:content) { '' }

        it 'fails' do
          assert_equal :invalid_input, result.error
          assert_nil result.uid
        end
      end

      describe "when the user updating the quote isn't the owner" do
        let(:user_uid) { 99 }

        it "fails" do
          assert_equal :invalid_user, result.error
          assert_nil result.uid
        end
      end
    end

    describe "with correct input" do
      it "returns the uid of the updated quote on success" do
        assert_nil result.error
        assert_equal 1, result.uid
      end

      it "updates the given quote" do
        assert_equal 1, loaded_quote.uid
        assert_equal 23, loaded_quote.added_by
        assert_equal 'updated content', loaded_quote.content
        assert_equal 1, loaded_quote.publication_uid
        assert_equal 3, loaded_quote.tags.size
        assert_equal 'Author', loaded_quote.author
        assert_equal 'Title', loaded_quote.title
        assert_equal 'Publisher', loaded_quote.publisher
        assert_equal 1963, loaded_quote.year
      end
    end

    describe 'when the publication uid has changed' do
      let(:new_publication) { create_publication :title => 'A Different Publication'}
      let(:updates) do
        {
          :publication_uid => new_publication.uid
        }
      end

      it 'updates the quote with new publication information' do
        assert_equal 1, loaded_quote.uid
        assert_equal new_publication.uid, loaded_quote.publication_uid
        assert_equal new_publication.title, loaded_quote.title
      end
    end
  end
end

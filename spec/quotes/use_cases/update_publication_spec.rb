require 'spec_helper'

class UpdatePublicationSpec < UseCaseSpec
  let(:uid) { 1 }
  let(:user_uid) { 23 }
  let(:updates) do
    { :author => 'updated author'}
  end
  let(:input) do
    {
      :user_uid => user_uid,
      :uid => uid,
      :updates => updates
    }
  end
  let(:use_case) { Quotes::UseCases::UpdatePublication.new(input) }

  describe "call" do
    before { create_publication }
    let(:result) { use_case.call }
    let(:loaded_publication) { publications_gateway.get(result.uid) }

    describe "with invalid input" do
      describe "with a non-existent publication" do
        let(:uid) { 99 }

        it "fails" do
          assert_equal :publication_not_found, result.error
          assert_nil result.uid
        end
      end

      describe "when the user updating the publication isn't the owner" do
        let(:user_uid) { 99 }

        it "fails" do
          assert_equal :invalid_user, result.error
          assert_nil result.uid
        end
      end
    end

    describe "with correct input" do
      it "returns the uid of the updated publication on success" do
        assert_nil result.error
        assert_equal 1, result.uid
      end

      it "updates the given publication" do
        assert_equal 1, loaded_publication.uid
        assert_equal 23, loaded_publication.added_by
        assert_equal 'updated author', loaded_publication.author
        assert_equal 'Title', loaded_publication.title
        assert_equal 'Publisher', loaded_publication.publisher
        assert_equal 1963, loaded_publication.year
      end
    end
  end
end

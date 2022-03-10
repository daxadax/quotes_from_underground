require 'spec_helper'

class DeletePublicationSpec < UseCaseSpec
  let(:input) do
    {
      :user_uid => user_uid,
      :uid => publication_uid
    }
  end
  let(:user_uid) { 23 }
  let(:use_case) { Quotes::UseCases::DeletePublication.new(input) }

  describe "call" do
    before { create_publications }
    let(:result) { use_case.call }

    describe "with unexpected input" do
      describe 'with invalid input' do
        let(:publication_uid) { 'not a valid uid' }

        it "fails" do
          assert_equal :invalid_input, result.error
          assert_all_publications_present
        end
      end

      describe 'with wrong user_uid' do
        let(:publication_uid) { publications_gateway.all.last.uid }
        let(:user_uid) { 24 }

        it 'fails' do
          assert_equal :invalid_user, result.error
          assert_all_publications_present
        end
      end
    end

    describe "with expected input" do
      let(:publication_uid) { publications_gateway.all.last.uid }

      it "deletes the publication with the given publication_uid" do
        assert_all_publications_present

        assert_nil result.error

        assert_equal 4, publications_gateway.all.count
        assert_nil publications_gateway.get(publication_uid)
      end
    end
  end

  def assert_all_publications_present
    assert_equal 5, publications_gateway.all.count
  end

  def create_publications
    5.times { create_publication }
  end
end

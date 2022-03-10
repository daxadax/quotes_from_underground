require 'spec_helper'

class CreatePublicationSpec < UseCaseSpec
  let(:publication) { build_serialized_publication :no_json => true }
  let(:user_uid) { 23 }
  let(:input) do
    {
      :user_uid => user_uid,
      :publication => publication }
  end
  let(:use_case) { Quotes::UseCases::CreatePublication.new(input) }

  describe "call" do
    let(:result) { use_case.call }
    let(:loaded_publication)  { publications_gateway.get(result.uid) }

    describe "with unexpected input" do
      describe "with no publication" do
        before { input.delete(:publication) }

        it "fails" do
          assert_equal :invalid_input, result.error
          assert_nil result.uid
        end
      end

      describe 'without an author' do
        before { input[:publication][:author] = nil }

        it "fails" do
          assert_equal :invalid_input, result.error
          assert_nil result.uid
        end
      end

      describe "without a title" do
        before { input[:publication][:title] = nil }

        it "fails" do
          assert_equal :invalid_input, result.error
          assert_nil result.uid
        end
      end

      describe "without a year" do
        before { input[:publication][:year] = nil }

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
    end

    it "builds a new publication and saves it to the database" do
      assert_nil result.error

      assert_equal 1, loaded_publication.uid
      assert_equal user_uid, loaded_publication.added_by
      assert_equal "author", loaded_publication.author
      assert_equal 'title', loaded_publication.title
      assert_equal 'publisher', loaded_publication.publisher
      assert_equal 1999, loaded_publication.year
    end

    it "returns the uid of the newly created publication on success" do
      assert_nil result.error
      assert_equal 1, result.uid
    end
  end
end

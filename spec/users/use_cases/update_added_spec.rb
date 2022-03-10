require 'spec_helper'

class UpdateAddedSpec < UseCaseSpec
  let(:input) do
    { :uid => user_uid }
  end
  let(:use_case) do
    Users::UseCases::UpdateAdded.new(input)
  end
  let(:result) { update_added }

  before { @user = create_user }

  describe "call" do
    describe "with an unpersisted user" do
      before do
        input[:uid] = user_uid + 23
        input[:quote_uid] = 99
      end

      it "returns an error message, but does not update anything" do
        assert_equal  :user_not_found, result.error
      end
    end

    describe 'with nothing to update' do
      it 'returns an error message, but does not update anything' do
        assert_equal  :nothing_to_update, result.error

        assert_empty loaded_user.added_quotes
        assert_empty loaded_user.added_publications
      end
    end

    describe "success" do
      describe "with a quote and a persisted user" do
        before do
          input[:quote_uid] = 99
        end

        it "adds the quote's uid to the user's added array" do
          assert_nil result.error
          assert_includes loaded_user.added_quotes, input[:quote_uid]
        end

        it 'removes that quote uid if it already exists' do
          update_added
          assert_equal [99], loaded_user.added_quotes

          result = update_added
          assert_nil result.error
          assert_empty loaded_user.added_quotes
        end
      end

      describe "with a publication and a persisted user" do
        before do
          input[:publication_uid] = 89
        end

        it "adds the publication's uid to the user's added array" do
          assert_nil result.error
          assert_equal [89], loaded_user.added_publications
        end

        it 'removes that publication uid if it already exists' do
          update_added
          assert_equal [89], loaded_user.added_publications

          result = update_added
          assert_nil result.error
          assert_empty loaded_user.added_publications
        end
      end
    end
  end

  def update_added
    use_case.call
  end

  def loaded_user
    users_gateway.get(user_uid)
  end

  def user_uid
    @user.uid
  end
end

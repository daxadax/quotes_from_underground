require 'spec_helper'

class ToggleFavoriteSpec < UseCaseSpec
  let(:input) do
    {
      :uid => nil,
      :quote_uid => 99
    }
  end
  let(:use_case) { Users::UseCases::ToggleFavorite.new(input) }

  describe "call" do
    describe "with an unpersisted user" do
      before do
        user_uid = create_user.uid
        input[:uid] = user_uid + 23
      end

      it "returns an error message, but does not update anything" do
        result = use_case.call

        assert_equal  :user_not_found, result.error
      end
    end

    describe "with correct input and a persisted user" do
      it "adds or removes the given quote from the given user's favorites" do
        user_uid = create_user.uid
        input[:uid] = user_uid
        use_case.call
        user = users_gateway.get(user_uid)

        assert_includes user.favorites, input[:quote_uid]

        use_case.call
        user = users_gateway.get(user_uid)

        refute_includes user.favorites, input[:quote_uid]
      end
    end
  end
end

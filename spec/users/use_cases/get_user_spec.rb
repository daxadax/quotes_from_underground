require 'spec_helper'

class GetUserSpec < UseCaseSpec
  let(:user) { create_user }
  let(:input) { {:uid => user.uid} }
  let(:use_case) { Users::UseCases::GetUser.new(input) }

  describe "call" do
    let(:result) { use_case.call }

    describe "with unexpected input" do
      let(:user) { build_user }

      it "fails" do
        assert_nil result.user
        assert_equal :invalid_input, result.error
      end
    end

    it "retrieves the user with the given user uid as a bound object" do
      assert_nil result.error

      assert_equal user.uid, result.user.uid
      assert_equal user.nickname, result.user.nickname
      assert_equal user.email, result.user.email
      assert_equal user.favorites, result.user.favorites
      assert_equal user.added_quotes, result.user.added_quotes
      assert_equal user.added_publications, result.user.added_publications
      assert_equal user.terms_accepted?, result.user.terms_accepted
    end
  end

end

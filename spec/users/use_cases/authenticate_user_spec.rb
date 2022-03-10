require 'spec_helper'

class AuthenticateUserSpec < UseCaseSpec

  let(:nickname)  { 'nickname' }
  let(:auth_key)  { 'auth_key' }
  let(:use_case) do
    input = {
      :nickname => nickname,
      :auth_key => auth_key
    }

    Users::UseCases::AuthenticateUser.new(input)
  end

  describe "call" do
    let(:result) { use_case.call }

    describe "with unexpected nickname" do
      let(:nickname) { '' }

      it "fails" do
        assert_failure { result }
      end
    end

    describe "with unexpected auth_key" do
      let(:auth_key) { '' }

      it "fails" do
        assert_failure { result }
      end
    end

    describe "no matching user is found" do
      it "returns an error message, but no user" do
        assert_equal  :user_not_found, result.error
        assert_nil result.uid
      end
    end

    describe "matching user is found" do
      before do
        create_user :auth_key => BCrypt::Password.create('auth_key')
      end

      describe "when auth_keys match" do
        it "returns the user's uid" do
          assert_nil    result.error
          assert_equal  1, result.uid
        end
      end

      describe "when auth_keys do not match" do
        let(:auth_key) { 'not_the_right_auth_key' }

        it "fails" do
          assert_equal  :auth_failure, result.error
          assert_nil result.uid
        end
      end
    end
  end
end

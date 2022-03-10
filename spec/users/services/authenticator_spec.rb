require 'spec_helper'

class AuthenticatorSpec < UseCaseSpec
  let(:nickname) { 'nickname' }
  let(:auth_key) { 'auth_key' }
  let(:authenticator) { Users::Services::Authenticator.new }
  let(:result) { authenticator.for(nickname, auth_key) }

  describe "no matching user is found" do
    let(:nickname) { 'unknown_user' }

    it "returns an error key but no user" do
      assert_equal :user_not_found, result
    end
  end

  describe "matching user is found" do
    before do
      create_user :auth_key => BCrypt::Password.create('auth_key')
    end

    it "returns the user's uid" do
      assert_equal 1, result
    end

    describe "auth_key does not match" do
      let(:auth_key) { BCrypt::Password.create('wrong key') }

      it "returns an error key but no user" do
        assert_equal :auth_failure, result
      end
    end

  end
end

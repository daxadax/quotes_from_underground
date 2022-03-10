require 'spec_helper'

class CreateUserSpec < UseCaseSpec

  let(:user) { build_serialized_user }
  let(:use_case) { Users::UseCases::CreateUser.new(input) }
  let(:input) do
    {
      :nickname => 'nickname',
      :email => 'email',
      :auth_key => 'auth_key'
    }
  end

  describe "call" do
    let(:result) { use_case.call }
    let(:loaded_user) { users_gateway.get(result.uid) }

    describe "with unexpected input" do
      describe "without nickname" do
        before { input.delete(:nickname) }

        it "fails" do
          assert_equal :invalid_input, result.error
        end
      end

      describe "without email" do
        before { input.delete(:email) }

        it "fails" do
          assert_equal :invalid_input, result.error
        end
      end

      describe "without auth_key" do
        before { input.delete(:auth_key) }

        it "fails" do
          assert_equal :invalid_input, result.error
        end
      end
    end

    it "builds a new user and saves it to the database" do
      assert_nil result.error

      assert_equal 1, loaded_user.uid
      assert_equal 'nickname',  loaded_user.nickname
      assert_equal 'email', loaded_user.email
      assert_equal BCrypt::Password.new(loaded_user.auth_key), "auth_key"
      assert_empty loaded_user.favorites
      assert_empty loaded_user.added_quotes
      assert_empty loaded_user.added_publications
    end

    it "returns the uid of the newly created user on success" do
      assert_nil result.error
      assert_equal 1, result.uid
    end

    describe 'user with duplicate nickname' do
      before { create_user }

      it 'fails' do
        assert_equal :duplicate_user, result.error
        assert_nil result.uid
      end
    end

  end
end

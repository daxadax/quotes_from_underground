require 'spec_helper'

class GetUsersSpec < UseCaseSpec
  let(:use_case)  { Users::UseCases::GetUsers.new }

  describe "call" do
    let(:result)        { use_case.call }
    let(:first_result)  { result.users.first }

    describe "with no users in the db" do
      let(:users) { nil }

      it "returns an empty array" do
        assert_empty  result.users
      end
    end

    describe "with 50 users in the db" do
      before do
        50.times { create_user }
      end

      it "retrieves all users from the backend in the form of bound objects" do
        assert_equal 50, result.users.size
        assert_kind_of Users::UseCases::GetUsers::Result, result
        assert_kind_of Users::Services::UserBoundary::User, first_result

        assert_equal 1, first_result.uid
        assert_equal 'nickname', first_result.nickname
        assert_equal 'email', first_result.email
      end
    end
  end
end

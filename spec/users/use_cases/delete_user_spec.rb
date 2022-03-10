require 'spec_helper'

class DeleteUserSpec < UseCaseSpec
  let(:uid) { users_gateway.all.last.uid }
  let(:input) { {:uid => uid} }
  let(:use_case) { Users::UseCases::DeleteUser.new(input) }
  let(:result) {  use_case.call }

  describe "call" do
    before { 5.times { create_user } }

    it "deletes the user with the given uid" do
      assert_equal 5, users_gateway.all.count

      use_case.call

      assert_equal 4, users_gateway.all.count
      assert_nil users_gateway.get(uid)
    end
  end
end

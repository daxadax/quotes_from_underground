require 'spec_helper'

class UsersGatewayBackendSpec < GatewayBackendSpec
  let(:user) { build_serialized_user }
  let(:user_to_update) { build_serialized_user(:uid => 1, :nickname => 'new') }
  let(:backend) { Persistence::Gateways::UsersGatewayBackend.new }

  describe "insert" do
    it "ensures the added object is a Hash" do
      assert_failure { backend.insert(23) }
    end

    describe "with an already added user" do
      let(:user) { build_serialized_user(:uid => "already_here!") }

      it "fails" do
        assert_failure { backend.insert(user) }
      end
    end

    it "returns the uid of the inserted user on success" do
      user_uid = backend.insert(user)

      assert_equal 1, user_uid
    end
  end

  describe "get" do
    it "returns nil if the the user is not persisted" do
      assert_nil backend.get(23)
    end

    it "stores the serialized data in database" do
      user_uid = backend.insert user
      result = backend.get user_uid

      assert_storage result
    end
  end

  describe 'fetch' do
    it 'returns nil if the user is not found' do
      assert_nil backend.fetch('not a real nickname')
    end

    it 'finds the user by nickname' do
      backend.insert user
      result = backend.fetch user[:nickname]

      assert_storage result
    end
  end

  describe "all" do
    it "returns an empty array if the backend is empty" do
      assert_empty backend.all
    end

    it "returns all items in the backend" do
      backend.insert(user)
      backend.insert(user)
      result = backend.all

      assert_equal 2, result.size
      assert_equal user[:favorites], result[0][:favorites]
      assert_equal user[:added_quotes], result[0][:added_quotes]
      assert_equal user[:added_publications], result[0][:added_publications]
      assert_equal user[:last_login_time], result[0][:last_login_time]
      assert_equal user[:last_login_address], result[0][:last_login_address]
      assert_equal user[:login_count], result[0][:login_count]
    end
  end

  describe "update" do
    describe "without a persisted user" do
      it "fails" do
        assert_failure { backend.update(user) }
      end
    end

    it "updates any changed attributes" do
      backend.insert(user)
      backend.update(user_to_update)
      result = backend.get(user_to_update[:uid])

      refute_equal user, result
      assert_equal 'new', result[:nickname]
    end
  end

  describe "delete" do
    it "removes the user associated with the given id" do
      backend.insert(user)
      backend.delete(1)

      assert_nil backend.get(1)
    end

    it "doesn't remove other quotes" do
      backend.insert(user)
      backend.insert(user)
      backend.delete(1)

      assert_nil backend.get(1)
      assert_storage backend.get(2)
    end
  end

  private

  # TODO: boolean issue with terms
  def assert_storage(actual)
    assert_equal user[:nickname], actual[:nickname]
    assert_equal user[:email], actual[:email]
    assert_equal user[:auth_key], actual[:auth_key]
    assert_equal user[:favorites], actual[:favorites]
    assert_equal user[:added_quotes], actual[:added_quotes]
    assert_equal user[:added_publications], actual[:added_publications]
    assert_equal user[:terms].to_s, actual[:terms]
    assert_equal user[:last_login_time], actual[:last_login_time]
    assert_equal user[:last_login_address], actual[:last_login_address]
    assert_equal user[:login_count], actual[:login_count]
  end
end

require 'spec_helper'

class UserSpec < Minitest::Spec
  let(:options) { {} }
  let(:user) { build_user(options) }

  describe 'construction' do
    it 'can be built with three arguments' do
      assert_equal 'nickname', user.nickname
      assert_equal 'email', user.email
      assert_equal 'auth_key', user.auth_key
    end

    it "has sane defaults for non-required arguments" do
      assert_nil user.uid
      assert_empty user.favorites
      assert_empty user.added_quotes
      assert_empty user.added_publications
      assert_equal  false, user.terms_accepted?
      assert_equal nil, user.last_login_time
      assert_equal nil, user.last_login_address
      assert_equal 0, user.login_count
    end

    it "fails without required arguments" do
      assert_failure { Users::Entities::User.new(nil, 'email', 'auth_key' ) }
      assert_failure { Users::Entities::User.new('name', nil, 'auth_key' ) }
      assert_failure { Users::Entities::User.new('name', 'email', nil ) }
    end

    describe "with options" do
      let(:options) do
        {
          :uid => 1,
          :favorites => [23, 52, 99],
          :added_quotes => [23],
          :added_publications => [1, 3, 15],
          :terms => true,
          :last_login_time => Time.new(2000).to_i,
          :last_login_address => '23.0.2.5',
          :login_count => 23
        }
      end

      it "builds users with details from the options hash if present" do
        assert_equal 'nickname', user.nickname
        assert_equal 'email', user.email
        assert_equal 'auth_key', user.auth_key
        assert_equal 1, user.uid
        assert_equal 3, user.favorites.size
        assert_equal [23, 52, 99], user.favorites
        assert_equal 1, user.added_quotes.size
        assert_equal [23], user.added_quotes
        assert_equal 3, user.added_publications.size
        assert_equal [1, 3, 15], user.added_publications
        assert_equal true, user.terms_accepted?
        assert_equal Time.new(2000).to_i, user.last_login_time
        assert_equal '23.0.2.5', user.last_login_address
        assert_equal 23, user.login_count
      end
    end
  end

  describe 'updating' do
    let(:user) { build_user(:uid => 23, :login_count => 9) }
    let(:updates_hash) { Hash.new }
    let(:result) { user.update(updates_hash) }

    it 'does not overwrite old values unless updates exist' do
      assert_equal user.uid, result.uid
      assert_equal user.nickname, result.nickname
      assert_equal user.auth_key, result.auth_key
      assert_equal user.favorites, result.favorites
      assert_equal user.added_quotes, result.added_quotes
      assert_equal user.added_publications, result.added_publications
      assert_equal user.terms_accepted?, result.terms_accepted?
      assert_equal nil, result.last_login_time
      assert_equal nil, result.last_login_address
      assert_equal 9, result.login_count
    end

    describe 'with updated values' do
      let(:updates_hash) do
        {
          :last_login_time => Time.new(2005).to_i,
          :last_login_address => '24.1.3.6',
          :login_count => 10
        }
      end

      it 'updates all given values' do
        assert_equal user.uid, result.uid
        assert_equal user.nickname, result.nickname
        assert_equal user.auth_key, result.auth_key
        assert_equal user.favorites, result.favorites
        assert_equal user.added_quotes, result.added_quotes
        assert_equal user.added_publications, result.added_publications
        assert_equal user.terms_accepted?, result.terms_accepted?
        assert_equal Time.new(2005).to_i, result.last_login_time
        assert_equal '24.1.3.6', result.last_login_address
        assert_equal 10, result.login_count
      end
    end
  end

  describe 'update_added' do
    it 'adds or removes added quotes or publications from the user' do
      assert_empty user.added_quotes
      assert_empty user.added_publications

      user.update_added(:quotes, 23)
      user.update_added(:publications, 25)

      assert_includes user.added_quotes, 23
      assert_includes user.added_publications, 25

      user.update_added(:quotes, 23)
      user.update_added(:publications, 25)

      assert_empty user.added_quotes
      assert_empty user.added_publications
    end
  end
end

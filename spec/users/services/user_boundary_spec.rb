require 'spec_helper'

class UserBoundarySpec < Minitest::Spec
  let(:user)      { build_user }
  let(:boundary)  { Users::Services::UserBoundary.new }
  let(:result)    { boundary.for(user) }

  it "grants access to uid" do
    assert_equal user.uid, result.uid
  end

  it "grants access to nickname" do
    assert_equal user.nickname,  result.nickname
  end

  it "grants access to email" do
    assert_equal user.email, result.email
  end

  it "grants access to favorites" do
    assert_equal user.favorites, result.favorites
  end

  it "grants access to added_quotes" do
    assert_equal user.added_quotes, result.added_quotes
  end

  it "grants access to added_publications" do
    assert_equal user.added_publications, result.added_publications
  end

  it "grants access to terms_accepted" do
    assert_equal user.terms_accepted?,  result.terms_accepted
  end

  it 'grants access to last_login_time' do
    assert_equal user.last_login_time, result.last_login_time
  end

  it 'grants access to last_login_address' do
    assert_equal user.last_login_address, result.last_login_address
  end

  it 'grants access to login_count' do
    assert_equal user.login_count, result.login_count
  end
end

require 'spec_helper'

class UpdateUserSpec < UseCaseSpec
    let(:user_uid) { 1 }
    let(:updates) do
      {}
    end
    let(:auth_key) { 'auth_key' }
    let(:input) do
        {
            :uid => user_uid,
            :updates => updates,
            :auth_key => auth_key
        }
    end
    let(:use_case)  { Users::UseCases::UpdateUser.new(input) }

    describe "call" do
      let(:options_for_original_user) do
        {
          :auth_key => BCrypt::Password.create('auth_key')
        }
      end

      before { create_user(options_for_original_user) }

      let(:result) { use_case.call }
      let(:loaded_user) { users_gateway.get(result.uid) }

        describe 'with invalid arguments' do
            let(:auth_key) { '' }

            it 'fails' do
                assert_failure { result }
            end
        end

        describe 'with a non-existent user' do
          let(:user_uid) { 23 }

          it 'returns a :user_not_found error' do
            assert_equal :user_not_found, result.error
            assert_nil result.uid
          end
        end

        describe 'when authentication fails' do
          let(:auth_key) { 'invalid_auth_key' }

            it 'returns an :auth_failure error' do
                assert_equal :auth_failure, result.error
                assert_nil result.uid
            end
        end

        describe 'when authentication succeeds' do

            describe 'nickname?' do
              let(:updates) do
                { :nickname => 'new nickname' }
              end

              it 'can be updated' do
                assert_nil result.error
                assert_equal user_uid, result.uid
                assert_equal "new nickname", loaded_user.nickname
              end
            end

            describe 'auth_key?' do
              let(:updates) do
                { :auth_key => 'new auth_key' }
              end

              it 'can be updated' do
                assert_nil result.error
                assert_equal user_uid, result.uid
                assert_equal BCrypt::Password.new(loaded_user.auth_key), "new auth_key"
              end
            end

            describe 'email?' do
              let(:updates) do
                { :email => 'new email' }
              end

              it 'can be updated' do
                assert_nil result.error
                assert_equal user_uid, result.uid
                assert_equal "new email", loaded_user.email
              end
            end

            describe 'login count' do
              let(:options_for_original_user) do
                {
                  :auth_key => BCrypt::Password.create('auth_key'),
                  :login_count => 2
                }
              end
              let(:updates) do
                {:update_login_count => true }
              end

              it 'updates the user\'s login count if given key is detected' do
                assert_nil result.error
                assert_equal user_uid, result.uid
                assert_equal 3, loaded_user.login_count
              end
            end

            describe 'with unupdated existing optons' do
              let(:options_for_original_user) do
                {
                  :auth_key => BCrypt::Password.create('auth_key'),
                  :last_login_time => 1013
                }
              end

              it 'does not overwrite them' do
                assert_nil result.error
                assert_equal user_uid, result.uid
                assert_equal 1013, loaded_user.last_login_time
              end
            end

        end

    end
end

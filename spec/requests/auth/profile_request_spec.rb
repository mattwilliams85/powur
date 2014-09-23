require 'spec_helper'

describe '/u/profile' do

  before :each do
    login_user
  end

  # describe '#show' do
  #   it 'returns a user profile' do
  #     create_list(:user, 3)
  #     get profile_path, format: :html
  #     expect_200
  #     #expect_classes('profile_section')
  #   end
  # end

  # describe '/update_password' do
  #   it 'Updates the current user password' do
  #     @user.password = "huntingKnife"
  #     puts @user.first_name
  #     post update_password_profile_path, current_password: @user.password,
  #       new_password: 'dragonsAwake!', new_password_confirm: 'dragonsAwake!', format: :json

  #     expect_200
  #     expect_confirm

  #     user = User.authenticate(@user.email, 'dragonsAwake!')
  #     expect(user).to_not be_nil
  #   end
  # end

end
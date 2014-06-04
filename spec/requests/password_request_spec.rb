require 'spec_helper'

describe '/password' do

  before :each do
    @user = create(:user, 
      reset_token:  'token_value', 
      reset_sent_at: DateTime.current)
  end

  it 'is a valid token' do
    expect(@user.reset_token_expired?).to_not be
  end

  describe '/new' do

    it 'renders the password form with a valid reset token' do
      get new_login_password_path, token: @user.reset_token

      expect_200
      expect(response.body).to match(/Confirm Password/)
    end

  end

  describe '/create' do
    it 'accepts a request to change the password' do
      put login_password_path, token: @user.reset_token,
        password: 'new_password', password_confirm: 'new_password', format: :json

      expect_200
    end
  end

end
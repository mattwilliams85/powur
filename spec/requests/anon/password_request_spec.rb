require 'spec_helper'

describe '/password' do

  before do
    User.delete_all
    @user = create(:user,
                   reset_token:   'token_value',
                   reset_sent_at: DateTime.current)
  end

  it 'is a valid token' do
    expect(@user.reset_token_expired?).to_not be
  end

  describe '/new' do

    it 'renders the password form with a valid reset token' do
      get new_password_path, token: @user.reset_token

      expect_200
      expect(response.body).to match(/Confirm Password/)
    end

  end

  describe '#create' do

    it 'accepts a request to reset the password and sends the email' do
      user = create(:user)

      post password_path, email: user.email, format: :json

      expect_200
      expect_confirm
    end

  end

  describe '#update' do
    it 'accepts a request to change the password' do
      put password_path,
          token:            @user.reset_token,
          password:         'new_password',
          password_confirm: 'new_password',
          format:           :json

      expect_200
      expect_confirm

      user = User.authenticate(@user.email, 'new_password')
      expect(user).to_not be_nil
    end
  end
end

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

  describe '#create' do
    it 'accepts a request to reset the password and sends the email' do
      user = create(:user)

      post password_path, email: user.email, format: :json

      expect_200
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

    context 'when reset token expired' do
      before do
        @user.update_attribute(:reset_sent_at, DateTime.current - 2.days)
      end

      it 'returns unauthorized' do
        put password_path,
            token:            @user.reset_token,
            password:         'new_password',
            password_confirm: 'new_password',
            format:           :json

        expect(response.code).to eq('401')
      end
    end
  end
end

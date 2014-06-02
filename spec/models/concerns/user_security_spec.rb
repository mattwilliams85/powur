require 'spec_helper'

describe UserSecurity do

  it 'sets the reset password token' do
    user = create(:user)

    expect(user.reset_token_expired?).to be

    user.send_reset_password

    expect(user.reset_token).to_not be_nil
    expect(user.reset_sent_at).to_not be_nil
    expect(user.reset_token_expired?).to_not be
  end

  it 'resets an expired reset password token' do
    expired = DateTime.current - (UserSecurity::RESET_TOKEN_VALID_FOR + 1.hour)
    user = create(:user, reset_sent_at: expired)

    expect(user.reset_token_expired?).to be

    user.send_reset_password
    expect(user.reset_token_expired?).to_not be
  end
end
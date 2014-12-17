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

  describe '#update_sign_in_timestamps!' do
    let!(:user) { create(:user) }

    context 'when remember_me is not set' do
      it 'sets last_sign_in_at timestamp but not remember_me' do
        user.update_sign_in_timestamps!
        user.reload
        expect(user.remember_created_at).to be_nil
        expect(user.last_sign_in_at).to be_within(1).of(Time.now.utc)
      end
    end

    context 'when remember_me is true' do
      it 'sets last_sign_in_at and remember_me timestamp' do
        user.update_sign_in_timestamps!(true)
        user.reload
        expect(user.remember_created_at).to be_within(1).of(Time.now.utc)
        expect(user.last_sign_in_at).to be_within(1).of(Time.now.utc)
      end
    end
  end

  describe '#sign_in_expired?' do
    let(:user) { User.new }
    subject { user.sign_in_expired? }

    context 'when remember me timestamp is set' do
      before do
        allow(user).to receive(:remember_created_at).and_return(Time.now.utc)
        allow(user).to receive(:last_sign_in_at).and_return(Time.now.utc - 2.hours)
      end

      it { is_expected.to be false }
    end

    context 'when remember me timestamp is not set' do
      context 'when last sign in was 2 hours ago' do
        before do
          allow(user).to receive(:remember_created_at).and_return(nil)
          allow(user).to receive(:last_sign_in_at).and_return(Time.now.utc - 2.hours)
        end

        it { is_expected.to be true }
      end

      context 'when last sign in was less than an hour ago' do
        before do
          allow(user).to receive(:remember_created_at).and_return(nil)
          allow(user).to receive(:last_sign_in_at).and_return(Time.now.utc - 55.minutes)
        end

        it { is_expected.to be false }
      end
    end
  end
end

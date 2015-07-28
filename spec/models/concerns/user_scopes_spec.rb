require 'spec_helper'

describe UserScopes, type: :model do
  describe '.has_phone' do
    let!(:user_with_phone1) { create(:user, phone: '+1') }
    let!(:user_with_phone2) { create(:user, phone: '+2') }

    before do
      create(:user, phone: nil)
      create(:user, phone: '')
    end

    it 'should return users with a phone number' do
      users = User.has_phone
      expect(users.length).to eq(2)
      expect(users).to include(user_with_phone1, user_with_phone2)
    end
  end

  describe '.allows_sms' do
    let!(:user_without_profile_settings) { create(:user, allow_sms: nil) }
    let!(:user_allows_sms_false) { create(:user, allow_sms: false) }
    let!(:user_allows_sms_true) { create(:user, allow_sms: true) }

    it 'should return users who did not block sms' do
      users = User.allows_sms
      expect(users.length).to eq(2)
      expect(users)
        .to include(user_without_profile_settings, user_allows_sms_true)
    end
  end
end

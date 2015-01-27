require 'spec_helper'

describe UserSmarteru do

  describe '#has_smarteru_account?' do
    subject { user.has_smarteru_account? }
    let(:user) { create(:user) }

    it { is_expected.to eq(false) }

    context 'has smarter u employee id' do
      before do
        user.smarteru_employee_id = 123
      end

      it { is_expected.to eq(true) }
    end
  end

  describe '#create_smarteru_account' do
    subject { user.create_smarteru_account({password: password}) }
    let(:user) { create(:user) }
    let(:password) { SecureRandom.urlsafe_base64(8) }

    context 'already has smarter u account' do
      before do
        user.smarteru_employee_id = 123
        expect(user).to_not receive(:smarteru_client)
      end

      it { is_expected.to eq(true) }
    end

    context 'does not have smarter u account' do
      let(:payload) do
        {
          user: {
            info: {
              email: user.email,
              employee_i_d: user.id,
              given_name: user.first_name,
              surname: user.last_name,
              password: password,
              learner_notifications: 1,
              supervisor_notifications: 0,
              send_email_to: 'Self',
            },
            profile: {
              home_group: Rails.application.secrets.smarteru_group_name
            },
            groups: {
              group: {
                group_name: Rails.application.secrets.smarteru_group_name,
                group_permissions: ''
              }
            }
          }
        }
      end
      let(:smarteru_client) { double('smarteru_client') }
      before do
        expect(smarteru_client).to receive(:request).with('createUser', payload).and_return(api_response)
        allow(user).to receive(:smarteru_client).and_return(smarteru_client)
      end

      context 'api error' do
        let(:api_response) { double('api_response', success?: false) }
        it { is_expected.to eq(false) }
      end

      context 'api success' do
        let(:api_response) { double('api_response', success?: true) }
        it { is_expected.to eq(true) }
      end
    end
  end
end

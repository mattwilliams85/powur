require 'spec_helper'

describe UserSmarteru do
  let(:smarteru_client) { double('smarteru_client') }

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
    subject { user.create_smarteru_account({password: password, employee_i_d: employee_i_d}) }
    let(:user) { create(:user) }
    let(:password) { SecureRandom.urlsafe_base64(8) }
    let(:employee_i_d) { rand(10 ** 10) }

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
              employee_i_d: employee_i_d,
              given_name: user.first_name,
              surname: user.last_name,
              password: password,
              learner_notifications: 1,
              supervisor_notifications: 0,
              send_email_to: 'Self',
            },
            profile: {
              home_group: ENV['SMARTERU_GROUP_NAME']
            },
            groups: {
              group: {
                group_name: ENV['SMARTERU_GROUP_NAME'],
                group_permissions: ''
              }
            }
          }
        }
      end
      before do
        expect(smarteru_client).to receive(:request).with('createUser', payload).and_return(api_response)
        allow(user).to receive(:smarteru_client).and_return(smarteru_client)
      end

      context 'api error' do
        let(:api_response) { double('api_response', success?: false, error: {}) }
        it { is_expected.to eq(false) }
      end

      context 'api success' do
        let(:api_response) { double('api_response', success?: true) }
        it { is_expected.to eq(true) }
      end
    end
  end

  describe '#smarteru_enroll' do
    subject { user.smarteru_enroll(product) }
    let(:user) { create(:user, smarteru_employee_id: 123) }
    let(:product) { double('product', id: 789, smarteru_module_id: '456') }
    let(:enrollments) { double('enrollments') }
    let(:enrollment) { double('enrollment') }
    let(:payload) do
      {
        learning_module_enrollment: {
          enrollment: {
            user: {
              employee_i_d: user.smarteru_employee_id
            },
            group_name: ENV['SMARTERU_GROUP_NAME'],
            learning_module_i_d: product.smarteru_module_id
          }
        }
      }
    end
    before do
      allow(smarteru_client).to receive(:getLearnerReport).and_return(true)
      expect(smarteru_client).to receive(:request).with('enrollLearningModules', payload).and_return(api_response)
      allow(user).to receive(:smarteru_client).and_return(smarteru_client)
    end

    context 'api error' do
      let(:api_response) { double('api_response', result: nil, error: {error: {error_id: 'SOME_ERROR'}}) }
      it { is_expected.to eq(false) }
    end

    context 'api error already enrolled' do
      let(:api_response) { double('api_response', result: nil, error: {error: {error_id: 'ELM:19'}}) }
      before do
        expect(enrollments).to receive(:find_or_create_by).with(product_id: product.id).and_return(enrollment)
        expect(user).to receive(:product_enrollments).and_return(enrollments)
        allow(enrollment).to receive(:removed?).and_return(false)
      end
      it { is_expected.to eq(enrollment) }
    end

    context 'api success' do
      let(:api_response) { double('api_response', result: {enrollments: []}) }
      before do
        expect(enrollments).to receive(:find_or_create_by).with(product_id: product.id).and_return(enrollment)
        expect(user).to receive(:product_enrollments).and_return(enrollments)
        allow(enrollment).to receive(:removed?).and_return(false)
      end

      it do
        expect(enrollment).not_to receive(:reenroll!)
        is_expected.to eq(enrollment)
      end

      context 're-enroll if enrollment was removed' do
        before do
          allow(enrollment).to receive(:removed?).and_return(true)
          expect(enrollment).to receive(:reenroll!).and_return(true)
        end

        it { is_expected.to eq(enrollment) }
      end
    end
  end

  describe '#smarteru_sign_in' do
    subject { user.smarteru_sign_in }
    let(:user) { create(:user, smarteru_employee_id: 123) }
    let(:payload) do
      {
        security: {
          employee_i_d: user.smarteru_employee_id
        }
      }
    end
    before do
      expect(smarteru_client).to receive(:request).with('requestExternalAuthorization', payload).and_return(api_response)
      allow(user).to receive(:smarteru_client).and_return(smarteru_client)
    end

    context 'api error' do
      let(:api_response) { double('api_response', success?: false, error: {}) }
      it { is_expected.to eq(false) }
    end

    context 'api success' do
      let(:api_response) { double('api_response', success?: true, result: {redirect_path: 'http://redirecturl'}) }
      it { is_expected.to eq('http://redirecturl') }
    end
  end
end

require 'spec_helper'

describe 'POST /u/invites' do
  let!(:user) { login_user }

  let(:payload) do
    { email:      'example@example.com',
      first_name: 'Dilbert',
      last_name:  'Pickles' }
  end

  context 'when invite already exists' do
    let!(:invite) do
      create(:invite, sponsor: create(:user), email: payload[:email])
    end

    before do
      allow_any_instance_of(User).to receive(:partner?).and_return(true)
    end

    it 'returns a warning' do
      post invites_path, payload, format: :json

      expect_input_warning(:email)
    end

    it 'should create a new invite if warning confirmed' do
      post(invites_path,
           payload.merge(confirm_existing_email: '1'),
           format: :json)

      expect_props(
        status:     'pending',
        first_name: payload[:first_name],
        last_name:  payload[:last_name],
        email:      payload[:email])
    end
  end
end

require 'spec_helper'

describe '/invite' do
  before do
    DatabaseCleaner.clean
  end

  describe 'PATCH' do
    let(:mailchimp_list_api) do
      double(:mailchimp_list_api, members: mailchimp_members_api)
    end
    let(:mailchimp_members_api) { double(:mailchimp_members_api) }
    let(:sponsor) { create(:certified_user, available_invites: 3) }
    let(:invite) do
      create(:invite, sponsor: sponsor, email: 'newinvite@test.com')
    end
    let(:user_params) do
      {
        code:                  invite.id,
        first_name:            invite.first_name,
        last_name:             invite.last_name,
        email:                 invite.email,
        phone:                 '8585551212',
        zip:                   '92127',
        password:              'password',
        password_confirmation: 'password',
        tos:                   true,
        format:                :json }
    end

    before do
      allow_any_instance_of(Gibbon::Request)
        .to receive(:lists).and_return(mailchimp_list_api)
    end

    it 'requires a valid invite code' do
      patch invite_path, user_params.reject { |k, _v| k == :code }

      expect_input_error(:code)
    end

    it 'requires certain fields' do
      patch invite_path(format: :json), code: invite.id

      expect(json_body['error']).to eq(
        'type'    => 'input',
        'message' => 'Please input an email address, Encrypted password is required, First name is required, Last name is required, Password is required, Password must be at least 8 characters.',
        'input'   => 'email')
    end

    context 'when successfully creates user' do
      let(:mailchimp_response) do
        {
          'id': 'abc123'
        }
      end

      before do
        expect(mailchimp_members_api).to receive(:create).with(
          body: {
            email_address: user_params[:email],
            interests:     {
              User::MAILCHIMP_INTERESTS[:partners]  => false,
              User::MAILCHIMP_INTERESTS[:advocates] => true },
            status:        'subscribed',
            merge_fields:  {
              FNAME: user_params[:first_name],
              LNAME: user_params[:last_name] }
          }).once.and_return(mailchimp_response)
      end

      it 'registers a user and associates any outstanding invites' do
        VCR.use_cassette('invite_promoter_association') do
          patch invite_path(format: :json),
                JSON.dump(user_params),
                'CONTENT_TYPE' => 'application/json'
        end

        expect_200

        user_id = User.find_by(email: invite.email).id
        invite.reload
        expect(invite.user_id).to eq(user_id)
        expect(invite.user.mailchimp_id).to eq(mailchimp_response['id'])
      end
    end
  end
end

describe '/invite/validate' do
  before do
    DatabaseCleaner.clean
  end

  describe 'POST' do
    let(:agreement) { double(dwight: 'schrute', version: '1.0') }
    let(:sponsor) { create(:certified_user, available_invites: 3) }
    let(:user) { create(:user) }
    let(:invite) { create(:invite, user: user, sponsor: sponsor) }

    it 'renders an error with an invalid code' do
      post validate_invite_path, code: 'nope', format: :json

      expect_200
      expect_input_error(:code)
    end

    it 'returns an invite without an accept action if previously redeemed' do
      allow(ApplicationAgreement).to receive(:current).and_return(agreement)
      invite = create(:invite, sponsor: sponsor)
      invite.update_attribute(:user_id,  user.id)

      post validate_invite_path, code: invite.id, format: :json

      expect_200
      expect_props status: 'redeemed'
      expect(json_body['actions']).to be_nil
    end

    it 'returns an invite without an accept action if expired' do
      allow(ApplicationAgreement).to receive(:current).and_return(agreement)
      invite = create(:invite, sponsor: sponsor)
      invite.update_attribute(:expires,  (invite.expires -= 2.days))

      post validate_invite_path, code: invite.id, format: :json

      expect_200
      expect_props status: 'expired'
      expect(json_body['actions']).to be_nil
    end

    it 'returns an invite when the user has inputted a code' do
      allow(ApplicationAgreement).to receive(:current).and_return(agreement)
      invite = create(:invite, sponsor: sponsor)
      post validate_invite_path, code: invite.id, format: :json

      expect_200
      expect_classes('invite')
      expect_actions('accept_invite')
      expect_props latest_terms: agreement.as_json
    end
  end
end

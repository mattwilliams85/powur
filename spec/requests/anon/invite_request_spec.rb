require 'spec_helper'

describe '/invite' do
  before do
    DatabaseCleaner.clean
  end

  describe 'PATCH' do
    let(:mailchimp_list_api) { double(:mailchimp_list_api) }
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
      allow_any_instance_of(Gibbon::API)
        .to receive(:lists).and_return(mailchimp_list_api)
    end

    it 'requires a valid invite code' do
      patch invite_path, user_params.reject { |k, _v| k == :code }

      expect_input_error(:code)
    end

    it 'requires certain fields' do
      patch invite_path(format: :json),
            JSON.dump(code: invite.id),
            'CONTENT_TYPE' => 'application/json'

      expect(json_body['errors']).to eq(
        'first_name'            => ['First name is required'],
        'last_name'             => ['Last name is required'],
        'email'                 => ['Please input an email address'],
        'encrypted_password'    => ['Encrypted password is required'],
        'password'              => [
          'Password is required',
          'Password must be at least 8 characters.'],
        'password_confirmation' => ['Password confirmation is required']
      )
    end

    context 'when successfully creates user' do
      before do
        expect(mailchimp_list_api).to receive(:subscribe).with(
          id:           User::MAILCHIMP_LISTS[:all],
          email:        { email: user_params[:email] },
          merge_vars:   {
            FNAME: user_params[:first_name],
            LNAME: user_params[:last_name]
          },
          double_optin: false).once
      end

      it 'regesters a user and associates any outstanding invites' do
        VCR.use_cassette('invite_promoter_association') do
          patch invite_path(format: :json),
                JSON.dump(user_params),
                'CONTENT_TYPE' => 'application/json'
        end

        expect_200

        user_id = User.find_by(email: invite.email).id
        invite.reload
        expect(invite.user_id).to eq(user_id)
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

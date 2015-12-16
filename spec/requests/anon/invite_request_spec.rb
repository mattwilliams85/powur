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
        first_name:            invite.first_name,
        last_name:             invite.last_name,
        email:                 invite.email,
        phone:                 '8585551212',
        address:               '69 Cherry Hill',
        city:                  'Pleasantville',
        state:                 'NV',
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

    it 'requires certain fields' do
      patch anon_invite_path(invite.id)

      expect_input_error(:first_name)
    end

    context 'when successfully creates user' do
      let(:mailchimp_response) {{ 'id': 'abc123' }}

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
          patch anon_invite_path(id: invite.id, format: :json), user_params
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

describe '/invite/{code}' do
  before do
    DatabaseCleaner.clean
    allow(ApplicationAgreement).to receive(:current).and_return(agreement)
  end

  let(:agreement) { double(dwight: 'schrute', version: '1.0') }
  let(:sponsor) { create(:certified_user, available_invites: 3) }
  let(:user) { create(:user) }
  let(:redeemed_invite) { create(:invite, user: user, sponsor: sponsor) }
  let(:invite) { create(:invite, sponsor: sponsor) }

  it 'returns not found if previously redeemed' do
    get anon_invite_path(redeemed_invite.id), format: :json

    expect_404
  end

  it 'returns an invite when the user has inputted a code' do
    get anon_invite_path(invite.id), format: :json

    expect_200
    expect_classes('invite')
    expect_actions('accept_invite')
    expect_props latest_terms: agreement.as_json
  end

  it 'updates last viewed at field' do
    invite.update_attribute(:last_viewed_at, Time.zone.now - 1.month)
    get anon_invite_path(invite.id), format: :json

    expect_200
    expect(invite.reload.last_viewed_at)
      .to be_within(1.second).of(Time.zone.now)
  end
end

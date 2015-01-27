require 'spec_helper'

describe '/a/invite' do
  before do
    DatabaseCleaner.clean
  end

  describe 'POST' do
    it 'renders an error with an invalid code' do
      post invite_path, code: 'nope', format: :json

      expect_200
      expect_input_error(:code)
    end

    it 'renders an error if an invite that already has been accepted' do
      user = create(:user)
      invite = create(:invite, user: user)

      post invite_path, code: invite.id, format: :json

      expect_input_error(:code)
    end

    it 'marks an invite for an existing user with same email address' do
      invite = create(:invite)
      user = create(:user, email: invite.email)

      post invite_path, code: invite.id, format: :json

      expect_input_error(:code)
      invite.reload
      expect(invite.user_id).to eq(user.id)
    end

    it 'returns an invite when the user has inputted a code' do
      invite = create(:invite)
      post invite_path, code: invite.id, format: :json

      expect_200
      expect_classes('invite')
      expect_actions('create')

      get root_url, format: :json

      expect_classes('session', 'registration')
    end

    it 'clears a code from session' do
      invite = create(:invite)
      post invite_path, code: invite.id, format: :json

      delete invite_path, format: :json
      expect_200
      expect_classes('session', 'anonymous')
    end
  end

  describe 'PATCH' do
    before(:each) do
      @invite = create(:invite)
      @user_params = {
        code:       @invite.id,
        email:      @invite.email,
        first_name: @invite.first_name,
        last_name:  @invite.last_name,
        phone:      '8585551212',
        zip:        '92127',
        password:   'password',
        password_confirmation:   'password',
        tos: true,
        format:     :json }
    end

    it 'requires a valid invite code' do
      patch invite_path, @user_params.reject { |k, _v| k == :code }

      expect_input_error(:code)
    end

    it 'requires certain fields' do
      patch invite_path(format: :json), JSON.dump({ code: @invite.id }), "CONTENT_TYPE" => "application/json"

      expect(json_body['errors']).to eq({
        "first_name" => ["First name is required"],
        "last_name" => ["Last name is required"],
        "encrypted_password" => ["Encrypted password is required"],
        "password" => ["Password is required", "Password not less than 8 symbols"],
        "password_confirmation" => ["Password confirmation is required"],
        "email" => ["Incorrect email address", "Please input an email address"],
        "phone" => ["Phone is required"],
        "tos" => ["You didn't agree to the terms and privacy policy"],
        "zip" => ["Zip is required"]
      })
    end

    it 'registers a new promoter' do
      VCR.use_cassette('ipayout_register') do
        patch invite_path(format: :json), JSON.dump(@user_params), "CONTENT_TYPE" => "application/json"
      end

      expect_200

      @invite.reload
      expect(@invite.user_id).to_not be_nil
    end

    it 'associates any outstanding invites with the new promoter' do
      invites = create_list(:invite, 2, email: @invite.email)
      VCR.use_cassette('invite_promoter_association') do
        patch invite_path(format: :json), JSON.dump(@user_params), "CONTENT_TYPE" => "application/json"
      end
      user_id = User.find_by(email: @invite.email).id
      invites.each do |invite|
        invite.reload
        expect(invite.user_id).to eq(user_id)
      end
    end
  end
end

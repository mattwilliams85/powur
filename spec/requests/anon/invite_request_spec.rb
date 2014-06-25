require 'spec_helper'

describe '/a/invite' do

  describe 'POST' do

    it 'renders an error with an invalid code' do
      post invite_path, code: 'nope', format: :json

      expect_200
      expect_input_error(:code)
    end

    it 'renders an error with an invite that already has already been accepted' do
      user = create(:user)
      invite = create(:invite, user: user)

      post invite_path, code: invite.id, format: :json

      expect_input_error(:code)
    end

    it 'marks an invite with an existing user with the same email address' do
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
        format:     :json }
    end

    it 'requires a valid invite code' do
      patch invite_path, @user_params.reject { |k,v| k == :code }

      expect_input_error(:code)
    end

    it 'requires certain fields' do
      [:email, :first_name, :last_name].each do |field|
        patch invite_path, @user_params.reject { |k,v| k == field }

        expect_input_error(field)
      end
    end

    it 'registers a new promoter' do
      patch invite_path, @user_params

      expect_200
      expect_classes('session', 'user')

      expect(json_body['properties']['first_name']).to include(@user_params[:first_name])

      @invite.reload
      expect(@invite.user_id).to_not be_nil
      expect(@invite.user_id).to eq(json_body['properties']['id'])
    end

    it 'associates any outstanding invites with the new promoter' do
      invites = create_list(:invite, 2, email: @invite.email)

      patch invite_path, @user_params

      id = json_body['properties']['id']
      invites.each do |invite|
        invite.reload
        expect(invite.user_id).to eq(id)
      end
    end

  end

end
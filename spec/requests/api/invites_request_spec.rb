require 'spec_helper'

describe '/api/invites', type: :request do
  before :each do
    login_api_user
    @user.profile = {"awarded_invites": 10}
    @user.save
  end

  describe 'GET /' do
    it 'returns a list of invites' do
      create_list(:invite, 3, sponsor: @user)

      get api_invites_path(format: :json, v: 1), token_param
      expect_classes('invites', 'list')
      expect(json_body['entities'].size).to eq(3)
    end
  end

  describe 'POST /' do
    let(:invite_params) do
      { email:        'paul.walker+invite@eyecuelab.com',
        first_name:   'paul',
        last_name:    'walker',
        phone:        '858.555.1212' }.merge(token_param)
    end

    it 'creates an invite' do
      post api_invites_path(format: :json, v: 1), invite_params

      expect_classes('invite')
      expect(json_body['properties']['email']).to eq(invite_params[:email])
    end
  end
end

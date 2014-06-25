require 'spec_helper'

describe '/a/users' do

  before :each do
    login_user
  end

  describe '#index' do

    it 'returns level 1 users' do
      create_list(:user, 3)
      create_list(:user, 2, sponsor: @user)

      get admin_users_path, format: :json

      expect_200

      expect_classes('users', 'list')
      expect(json_body['entities'].size).to eq(User.at_level(1).count)
    end

    it 'requires the user to be an admin' do
      @user.roles = []
      @user.save!

      get admin_users_path, format: :json

      expect(json_body.keys).to include('redirect')
    end

  end

  describe '#update' do

    let(:params) {{
      address:  '42 Sunshine Way',
      format:   :json }}

    it 'updates a user' do
      user = create(:user)

      patch admin_user_path(user), params

      expect_200
      expect(json_body['properties']['address']).to eq(params[:address])
    end

  end
end
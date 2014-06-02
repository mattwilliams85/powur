require 'spec_helper'

describe '/users' do

  before :each do
    login_user
  end

  it 'returns a list of the users belonging to the current user' do
    create_list(:user, 8, invitor: @user)

    get users_path, format: :json

    expect_200

    expect_classes('users', 'list')
    expect(json_body['entities']).to have(8).items
  end

  describe '/:id' do

    it 'returns the user detail' do
      get user_path(@user), format: :json

      expect_200
    end

  end


end
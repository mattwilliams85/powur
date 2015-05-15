require 'spec_helper'

describe '/login' do
  describe 'POST' do
    it 'requires an email' do
      post login_path, password: 'password', format: :json

      expect_input_error(:email)
    end

    it 'requires a password' do
      post login_path, email: 'somone@foo.com', format: :json

      expect_input_error(:password)
    end

    it 'authenticates the user' do
      @user = create(:user)
      post login_path, email: @user.email, password: 'password', format: :json

      expect_classes('user')
    end
  end
end

describe 'authenticate!' do
  context 'signed out' do
    it 'returns a 401 for XHR' do
      xhr :get, resources_path(format: :json)

      expect(response.status).to eq(401)
    end

    it 'responds with same standard html layout on any html request' do
      get(resources_path)
      resources_body = response.body
      get(root_path)
      root_body = response.body

      expect(resources_body).to eq(root_body)
    end

    it 'redirects to sign-in on json request' do
      get resources_path(format: :json)

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq('redirect' => '/')
    end
  end
end

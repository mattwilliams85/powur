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

      expect_classes('session', 'user')
    end
  end
end

describe 'authenticate!' do
  context 'signed out' do
    it 'returns a 401 for XHR' do
      xhr :get, dashboard_path

      expect(response.status).to eq(401)
    end

    it 'redirects to sign-in on request' do
      get dashboard_path

      expect(response.status).to eq(302)
    end
  end
end

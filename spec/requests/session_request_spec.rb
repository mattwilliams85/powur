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

  describe 'GET' do
    context 'when NOT signed in' do
      it 'should NOT redirect' do
        get '/login'
        expect(response).to have_http_status(200)
      end
    end

    context 'when signed in' do
      before do
        login_user
      end

      it 'should redirect to a dashboard' do
        get '/login'
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end
end

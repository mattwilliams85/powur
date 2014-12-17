require 'spec_helper'

describe IndexController do

  describe 'GET index' do
    let(:user) { mocked_user }

    before do
      expect(user).to receive(:sign_in_expired?).once.and_return(sign_in_expired?)
      expect(User).to receive(:find_by).with(id: user.id).once.and_return(user)
    end

    context 'when current sign in is expired' do
      let(:sign_in_expired?) { true }

      it 'does not redirect' do
        get :index, {format: :html}, {user_id: user.id}
        expect(response).to have_http_status(200)
      end
    end

    context 'when current sign in is NOT expired' do
      let(:sign_in_expired?) { false }

      it 'redirects to a dashboard' do
        get :index, {format: :html}, {user_id: user.id}, format: :html
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(dashboard_path)
      end
    end

  end
end

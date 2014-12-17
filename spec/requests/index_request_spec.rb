require 'spec_helper'

describe 'index' do
  it 'renders an anonymous session when the user is not logged in' do
    get root_path, format: :json

    expect_200

    expect_classes('session', 'anonymous')
    expect_actions('create', 'reset_password')
  end

  it 'renders a user session when the user is logged in' do
    login_user
    get root_path, format: :json

    expect_200
    expect_classes('session', 'user')
    expect_entities('user-invites', 'user-quotes', 'user-users')
    expect_actions('logout')
  end

  it 'returns registration when the user has inputted a code' do
    invite = create(:invite)
    post invite_path, code: invite.id, format: :json

    get root_path, format: :json

    expect_200
    expect_classes('session', 'registration')
    expect_actions('create')
  end

  context 'when NOT signed in' do
    it 'should NOT redirect' do
      get '/'
      expect(response).to have_http_status(200)
    end
  end

  context 'when signed in' do
    before do
      login_user
    end

    it 'should redirect to a dashboard' do
      get '/'
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(dashboard_path)
    end
  end
end

require 'spec_helper'

describe 'index' do
  context 'when signed out' do
    before do
      get root_path, format: :json
    end

    it 'renders an anonymous session data' do
      expect_200

      expect_classes('session', 'anonymous')
      expect_actions('create', 'reset_password')
    end
  end

  context 'when signed in' do
    before do
      expect_any_instance_of(User)
        .to receive(:update_login_streak).once
      login_user
      get root_path, format: :json
    end

    it 'renders user data' do
      expect_200
      expect_classes('session', 'user')
      expect_entities('user-invites', 'user-leads', 'user-users')
      expect_actions('logout')
    end
  end
end

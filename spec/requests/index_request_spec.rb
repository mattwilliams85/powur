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
    sponsor = create(:certified_user, available_invites: 1)
    invite = create(:invite, sponsor: sponsor)
    post invite_path, code: invite.id, format: :json

    get root_path, format: :json

    expect_200
    expect_classes('session', 'registration')
    expect_actions('create')
  end
end

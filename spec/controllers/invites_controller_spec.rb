require 'spec_helper'

describe InvitesController do

  before :each do
    login_user
  end

  let(:invite_params) {{
       email:       'paul.walker+invite@eyecuelab.com',
       first_name:  'paul',
       last_name:   'walker',
       phone:       '858.555.1212'
     }}

  it 'creates an invite' do
    post :create, invite_params

    expect(response.status).to eq(200)
  end

  it 'does not allow the user to exceed the max # of invites' do
    create_list(:invite, PromoterConfig.max_invites, invitor: @user)

    post :create, invite_params

    expect_alert_error
  end

end
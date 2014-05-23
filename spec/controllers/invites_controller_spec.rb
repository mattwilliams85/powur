require 'spec_helper'

describe InvitesController do

  before :each do
    session[:user_id] = create(:user).id
  end

  it 'creates an invite' do
    post :create,
       email:       'paul.walker+invite@eyecuelab.com',
       first_name:  'paul',
       last_name:   'walker',
       phone:       '858.555.1212'

    expect(response.status).to eq(200)
  end

end
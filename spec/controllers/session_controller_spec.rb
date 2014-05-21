require 'spec_helper'

describe SessionController do

  before :all do
    @user = create(:user)
    @user.password = 'password'
    @user.save!
  end

  it 'requires an email' do
    post :create, password: 'password'

    expect_input_error(:email)
  end

  it 'requires a password' do
    post :create, email: @user.email

    expect_input_error(:password)
  end

  it 'authenticates the user' do
    post :create, email: @user.email, password: 'password'

    expect(json_body.keys).to include('redirect')
  end

end
require 'spec_helper'

describe UsersController do
  render_views

  describe '#accept_invite' do

    it 'renders an error with an invalid code' do
      post :accept_invite, code: 'nope'

      expect_200
      expect_input_error(:code)
    end

    it 'accepts the invite with a valid code' do
      @invite = create(:invite)

      post :accept_invite, code: @invite.id
      
      expect_200
      expect(json_body['class']).to include('registration')
    end

  end

  describe '#create' do

    before(:each) do
      @invite = create(:invite)
      @user_params = {
        code:       @invite.id,
        email:      @invite.email,
        first_name: @invite.first_name,
        last_name:  @invite.last_name,
        phone:      '8585551212',
        zip:        '92127',
        password:   'password' }
    end

    it 'requires a valid invite code' do
      post :create, @user_params.reject { |k,v| k == :code }

      expect_input_error(:code)
    end

    it 'requires certain fields' do
      [:email, :first_name, :last_name, :phone, :zip].each do |field|
        post :create, @user_params.reject { |k,v| k == field }

        expect_input_error(field)
      end
    end

    it 'registers a new promoter' do
      post :create, @user_params

      expect_200

      expect(json_body['class']).to include('user')
      expect(json_body['properties']['email']).to include(@user_params[:email])
    end
  end
end

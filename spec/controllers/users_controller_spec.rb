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
end

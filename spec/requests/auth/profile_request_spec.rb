require 'spec_helper'

describe '/u/profile' do

  before :each do
    login_user
  end

  describe '#show' do

    it 'returns a user profile' do
      create_list(:user, 3)
      get profile_path, format: :html

      expect_200

      #expect_classes('profile_section')
      
    end
  end

  # describe '#update' do

  #   let(:params) {{
  #     phone:  '8888888888',
  #     format:   :json }}

  #   it 'updates a user' do
  #     user = current_user
  #     patch profile_path(user), params, format: :json
  #     expect_200
  #     #expect(json_body['properties']['phone']).to eq(params[:phone])
  #   end 
  # end
end

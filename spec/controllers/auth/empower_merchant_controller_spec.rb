require 'spec_helper'

RSpec.describe Auth::EmpowerMerchantController, type: :controller do

  render_views

  describe 'GET sandbox' do
    it 'renders the Empower Merchant Sandbox HTML page' do
      # user_activity login event is created during authentication
      login_real_user
      get :sandbox, format: :html
      expect(response.status).to eq(200)
    end
  end
end

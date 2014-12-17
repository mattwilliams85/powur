require 'spec_helper'

describe '/u/empower_merchant' do

  before do
    login_real_user
  end

  describe '#sandbox' do
    it "display has the text 'Empower Merchant Sandbox'" do
      get sandbox_empower_merchant_path
      expect_200
      expect(response.body).to match(/Empower Merchant Sandbox/)
    end
  end

end

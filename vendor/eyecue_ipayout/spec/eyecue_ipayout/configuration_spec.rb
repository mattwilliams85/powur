# spec/eyecue_ipayout/configuration_spec.rb

require "spec_helper"
require "eyecue_ipayout/configuration"
module EyecueIpayout
  describe Configuration do
    describe "#endpoint=" do
      it "can set value" do
        config = Configuration.new
        config.endpoint = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
        expect(config.endpoint).to eq('https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx')
      end
    end
  end
end
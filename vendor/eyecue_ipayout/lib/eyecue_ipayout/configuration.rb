module EyecueIpayout
  class Configuration
    attr_accessor :endpoint
    attr_accessor :merchant_guid
    attr_accessor :merchant_password

    def initialize
      @endpoint = nil
      @merchant_guid = nil
      @merchant_password = nil
    end

    def load_api_keys
      @endpoint = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
      @merchant_guid = 'a4739056-7db6-40f3-9618-f2bcccbf70cc'
      @merchant_password = '9xXLvA66hi'
    end
  end
end

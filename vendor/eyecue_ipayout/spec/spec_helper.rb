require 'bundler/setup'
Bundler.setup

require 'eyecue_ipayout'

RSpec.configure do |config|
  EyecueIpayout.configure do |config|
    config.endpoint = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
    config.merchant_guid = 'a4739056-7db6-40f3-9618-f2bcccbf70cc'
    config.merchant_password = '9xXLvA66hi'
  end
end



module EmpowerMerchantDSL
  extend ActiveSupport::Concern
  # require 'active_merchant'

  include EmpowerMerchantRequestHelper
  attr_accessor :client

  def empower_merchant_request(_params)
    # make an empower merchant request
  end

  def connect
    conn = establish_connection
  end

  def post(text)
    options = { body: { status: text } }
    self.class.post('/statuses/update.json', options)
  end
end

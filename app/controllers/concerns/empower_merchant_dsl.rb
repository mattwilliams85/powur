module EmpowerMerchantDSL
  extend ActiveSupport::Concern
  include EmpowerMerchantRequestHelper
  attr_accessor :client

  def empower_merchant_request(params)
    #make an empower merchant request
  end

  def connect
    conn = establish_connection
  end

  private

  # def ###
  # end
end
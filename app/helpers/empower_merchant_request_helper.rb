module EmpowerMerchantRequestHelper
  require 'nmi_direct_post'
  # def #########(user)
  #   #  helper stub
  # end
  @client = nil

  def establish_connection
    username = Rails.application.secrets.nmi_username
    password = Rails.application.secrets.nmi_password

    @client = NmiDirectPost::Base.establish_connection(username, password)
    client
  end

  def thisdef
    ag 'hi'
  end
end


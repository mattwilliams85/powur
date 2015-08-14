module UserEwallet
  extend ActiveSupport::Concern

  def ewallet_client
    @ewallet_client ||= EwalletClient.new
  end

  def ewallet?
    !ewallet_username.blank?
  end

  # Returns ewallet data in a hash format
  def ewallet
    return @ewallet if @ewallet
    result = ewallet_client.fetch(ewallet_username)
    @ewallet = result
  rescue Ipayout::Error::EwalletNotFound
    return nil
  end

  # Creates ewallet based on user's data
  # and sets ewallet_username attribute for future requests
  def ewallet!
    result = ewallet_client.create(self)
    success_messages = [ 'OK',
                         'A user with this UserName already exists' ]
    fail(result[:m_Text]) unless success_messages.include?(result[:m_Text])
    update_attributes!(ewallet_username: email)
  end

  def ewallet_auto_login_url
    result = ewallet_client.login_url(ewallet_username)
    ewallet_client.auto_login_endpoint +
      result[:ProcessorTransactionRefNumber].to_s
  end
end

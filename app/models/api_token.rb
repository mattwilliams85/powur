class ApiToken < ActiveRecord::Base
  belongs_to :client, class_name: 'ApiClient', foreign_key: 'client_id', inverse_of: :tokens
  belongs_to :user

  validates_presence_of :access_token, :client_id, :user_id, :expires_at

  SECONDS_TILL_EXPIRATION = (60 * 60 * 24) # 1 day

  before_validation do
    self.id ||= random_secret(64)
    self.access_token ||= random_secret(64)
    self.expires_at ||= SECONDS_TILL_EXPIRATION.seconds.from_now
  end

  def token_type
    'Bearer'
  end

  def expires_in
    expires_at.to_i - DateTime.current.to_i
  end

  def expired?
    DateTime.current >= expires_at
  end

  def refresh_token
    id
  end

  def refresh!
    client.tokens.create(user: user)
  end

  private

  def random_secret(size = 64)
    SecureRandom.hex(64)
  end
end

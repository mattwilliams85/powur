module UserSecurity
  extend ActiveSupport::Concern

  RESET_TOKEN_VALID_FOR = 24.hours

  module ClassMethods
    def authenticate(email, password)
      user = if SystemSettings.case_sensitive_auth
        find_by(email: email)
      else
        where('lower(email) = ?', email.downcase).first
      end
      user && user.password_match?(password) ? user : nil
    end

    def random_code(size = 15)
      SecureRandom.urlsafe_base64(size)
    end
  end

  def password=(value)
    @password = value
    self.encrypted_password = hash_password(value) if @password.present?
  end

  def password_match?(value)
    return false if encrypted_password.blank? || value.blank?
    bcrypt = ::BCrypt::Password.new(encrypted_password)
    password = ::BCrypt::Engine.hash_secret(value, bcrypt.salt)
    SameTime.equal?(encrypted_password, password)
  end

  def reset_token_expires_at
    reset_sent_at + RESET_TOKEN_VALID_FOR
  end

  def reset_token_expired?
    reset_sent_at.nil? || reset_token.nil? ||
      DateTime.current > reset_token_expires_at
  end

  def ensure_reset_password_token
    return unless reset_token_expired?
    update_attributes!(
      reset_token:   self.class.random_code,
      reset_sent_at: DateTime.current)
  end

  def send_reset_password
    ensure_reset_password_token

    PromoterMailer.reset_password(self).deliver_later
  end

  # Updates last_sign_in_at and remember_created_at timestamps
  def update_sign_in_timestamps!(remember_me = false)
    timestamp = Time.now.utc
    self.last_sign_in_at = timestamp
    self.remember_created_at = timestamp if remember_me
    save(validate: false)
  end

  def update_login_streak!(timestamp)
    unless last_login_streak_at
      update_attributes(
        last_login_streak_at: timestamp.to_date.to_s(:db),
        login_streak:         1)
      return
    end

    yesterday_date = timestamp.yesterday.to_date
    last_streak_date = Time.zone.parse(last_login_streak_at).to_date
    streak = login_streak

    if yesterday_date == last_streak_date
      streak += 1
    elsif yesterday_date >= last_streak_date
      streak = 1
    end

    update_attributes(
      last_login_streak_at: timestamp.to_date.to_s(:db),
      login_streak:         streak)
  end

  private

  def hash_password(value)
    ::BCrypt::Password.create(value, cost: 10).to_s
  end
end

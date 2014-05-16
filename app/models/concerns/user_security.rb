module UserSecurity
  extend ActiveSupport::Concern

  module ClassMethods

    def authenticate(email, password)
      user = self.find_by(email: email)
      user && user.password_match?(password) ? user : nil
    end

  end

  def password=(value)
    @password = value
    self.encrypted_password = hash_password(value) if @password.present?
  end

  def password_match?(value)
    return false if self.encrypted_password.blank? || value.blank?
    bcrypt = ::BCrypt::Password.new(self.encrypted_password)
    password = ::BCrypt::Engine.hash_secret(value, bcrypt.salt)
    SameTime.equal?(self.encrypted_password, password)
  end

  private 

  def hash_password(value)
    ::BCrypt::Password.create(value, :cost => 10).to_s
  end

end
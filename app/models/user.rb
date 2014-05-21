class User < ActiveRecord::Base
  include UserSecurity

  validates :email, email: true, presence: true

end

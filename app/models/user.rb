class User < ActiveRecord::Base
  include UserSecurity
  include UserInvites

  validates :email, email: true, presence: true
  validates_presence_of :encrypted_password, on: :create
  validates_presence_of :first_name, :last_name, :phone, :zip

end

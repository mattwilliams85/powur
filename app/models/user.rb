class User < ActiveRecord::Base
  include UserSecurity
  include UserInvites

  validates :email, email: true, presence: true
  validates_presence_of :encrypted_password, on: :create
  validates_presence_of :first_name, :last_name, :phone, :zip

  has_many :customers, foreign_key: 'promoter_id'

  def full_name
    "#{first_name} #{last_name}"
  end

  def create_customer(params)
    self.customers.create!(params)
  end


end

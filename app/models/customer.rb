class Customer < ActiveRecord::Base
  include NameEmailSearch
  # after_create :email_customer

  # enum status: [ :incomplete, :complete, :submitted, :accepted, :voided, :installed ]

  validates_presence_of :first_name, :last_name
  validates_presence_of :email, :phone, :address, :city, :state, :zip, allow_nil: true

  has_many :quotes

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

end
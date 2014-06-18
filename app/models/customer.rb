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

  def data_status
    data = []
    data << :phone if self.phone
    data << :email if self.email
    data << :address if self.address && self.city && self.state && self.zip
    data << :utility if self.kwh
    data
  end


end
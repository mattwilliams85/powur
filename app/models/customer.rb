class Customer < ActiveRecord::Base
  include NameEmailSearch

  validates_presence_of :first_name, :last_name
  validates_presence_of :email, :phone, :address, :city, :state, :zip,
                        allow_nil: true

  has_many :quotes
  has_many :notes

  def full_name
    "#{first_name} #{last_name}"
  end
end

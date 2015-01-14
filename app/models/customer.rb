class Customer < ActiveRecord::Base
  include NameEmailSearch

  validates_presence_of :first_name, :last_name
  validates_presence_of :email, :phone, :address, :city, :state, :zip,
                        allow_nil: true

  has_many :quotes
  has_many :notes

  def complete?
    %w(first_name last_name email phone address city state zip).all? do |f|
      !attributes[f].nil?
    end
  end

  def address_complete?
    address && city && state && zip
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end

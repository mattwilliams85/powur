class Customer < ActiveRecord::Base
  include NameEmailSearch

  validates_presence_of :first_name, :last_name
  validates_presence_of :email, :phone, :address, :city, :state, :zip,
                        allow_nil: true
  validates_length_of :first_name, maximum: 40
  validates_length_of :last_name, maximum: 40

  has_many :quotes

  def complete?
    %w(first_name last_name email phone address city state zip).all? do |f|
      !attributes[f].nil?
    end
  end

  def address_complete?
    !address.nil? && !city.nil? && !state.nil? && !zip.nil?
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end

class Customer < ActiveRecord::Base
  include NameEmailSearch

  belongs_to :user

  validates_presence_of :first_name, :last_name
  validates_presence_of :email, :phone, :address, :city, :state, :zip,
                        allow_nil: true
  validates_length_of :first_name, maximum: 40
  validates_length_of :last_name, maximum: 40

  before_validation do
    self.code ||= Invite.generate_code
  end

  enum status: [ :sent, :initiated, :accepted, :ineligible_location ]

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

  def full_address
    "#{address}, #{city}, #{state} #{zip}"
  end

  def lead
    @lead ||= Lead.where(customer_id: id).first
  end

  def lead?
    !lead.nil?
  end

  def lead_submitted?
    lead? && lead.submitted?
  end
end

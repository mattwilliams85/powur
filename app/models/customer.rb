require 'valid_email'

class Customer < ActiveRecord::Base
  include NameEmailSearch
  include Phone

  belongs_to :user

  validates_presence_of :first_name, :last_name
  validates_presence_of :email, :phone, :address, :city, :state, :zip,
                        allow_nil: true
  validates_length_of :first_name, maximum: 40
  validates_length_of :last_name, maximum: 40
  validates :email, presence:   true,
                    email:      true,
                    uniqueness: true, if: :email_present?
  def email_present?
    email?
  end

  validates_with ::Phone::Validator, fields: [:phone],
                                     if:     'phone.present?',
                                     on:     :create

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

  def send_sms
    return if phone.nil? || !valid_phone?(phone)
    host = Rails.configuration.action_mailer.default_url_options[:host]
    join_url = URI.join(host, 'next/join/solar', code)
    message = I18n.t('sms.solar_invite', name: user.full_name, url: join_url)

    twilio_client = TwilioClient.new
    twilio_client.send_message(
      to:   phone,
      from: twilio_client.purchased_numbers.sample,
      body: message)
  end
end

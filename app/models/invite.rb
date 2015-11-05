require 'valid_email'

class Invite < ActiveRecord::Base
  include NameEmailSearch
  include Phone

  belongs_to :user, class_name: 'User'
  belongs_to :sponsor, class_name: 'User'

  # Validates with https://github.com/hallelujah/valid_email
  validates :email, presence:   true,
                    email:      true,
                    uniqueness: true, if: :email_present?
  def email_present?
    email?
  end

  validates :first_name, :last_name, presence: true
  validates :phone, presence: true, allow_nil: true
  # validate :max_invites, on: :create, if: :sponsor_limited_invites?
  validates_with ::Phone::Validator, fields: [:phone],
                                     if:     'phone.present?',
                                     on:     :create

  # after_create :subtract_from_available_invites, if: :sponsor_limited_invites?
  # after_destroy :increment_available_invites, if: :sponsor_limited_invites?
  # def sponsor_limited_invites?
  #   sponsor.limited_invites?
  # end

  before_validation do
    self.id ||= self.class.generate_code
    self.expires ||= expires_timespan
  end

  scope :pending, -> { where(user_id: nil).where('expires > ?', Time.zone.now) }
  scope :expired, -> { where(user_id: nil).where('expires < ?', Time.zone.now) }
  scope :redeemed, -> { where.not(user_id: nil) }

  scope :status, ->(s) { send(s) }

  class << self
    def generate_code(size = 3)
      code = SecureRandom.hex(size).upcase
      find_by(id: code) ? generate_code(size) : code
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def expired?
    expires < Time.zone.now
  end

  def redeemed?
    !user_id.nil?
  end

  def status
    if redeemed?
      :redeemed
    elsif expired?
      :expired
    else
      :pending
    end
  end

  def pending?
    status == :pending
  end

  def renew
    update_attributes(expires: expires_timespan)
  end

  def accept(params)
    params[:sponsor_id] = sponsor_id

    user = User.new(params)

    latest_agreement = ApplicationAgreement.current
    if latest_agreement && latest_agreement.version != params[:tos]
      user.errors.add(
        :tos,
        'Please read and agree to the latest terms and conditions in ' \
        'the Application and Agreement')
      return user
    end

    Invite.where(id: id).update_all(user_id: user.id) if user.save!

    user
  end

  def expires_timespan
    SystemSettings.invite_valid_days.days.from_now
  end

  def time_left
    time_left = (expires.in_time_zone - Time.now) * 1000.0
    time_left <= 0 ? (return 0) : (return time_left)
  end

  def send_sms
    return if phone.nil? || !valid_phone?(phone)

    opts = Rails.configuration.action_mailer.default_url_options
    join_url = URI.join("#{opts[:protocol]}://#{opts[:host]}",
                        'next/join/grid/',
                        id).to_s
    message = I18n.t('sms.grid_invite', name: sponsor.full_name, url: join_url)

    twilio_client = TwilioClient.new
    twilio_client.send_message(
      to:   phone,
      from: twilio_client.numbers_for_personal_sms.sample,
      body: message)
  end

  def mandrill
    return nil unless mandrill_id
    @mandrill ||= MandrillMonitor.new(mandrill_id)
  end

  # def max_invites
  #   return if sponsor.available_invites > 0
  #   errors.add(:sponsor, :exceeded_max_invites)
  # end

  # def subtract_from_available_invites
  #   sponsor.update_column(:available_invites, sponsor.available_invites - 1)
  # end

  # def increment_available_invites
  #   sponsor.update_column(:available_invites, sponsor.available_invites + 1)
  # end
end

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
  validate :max_invites, on: :create
  validates_with ::Phone::Validator, fields: [:phone],
                                     if:     'phone.present?',
                                     on:     :create

  after_create :subtract_from_available_invites
  after_destroy :increment_available_invites

  before_validation do
    self.id ||= Invite.generate_code
    self.expires ||= expires_timespan
  end

  scope :pending, -> { where(user_id: nil).where('expires > ?', Time.zone.now) }
  scope :redeemed, -> { where.not(user_id: nil) }
  scope :expired, lambda {
    where('expires < ?', Time.zone.now).where('user_id IS NOT NULL')
  }

  def full_name
    "#{first_name} #{last_name}"
  end

  def status
    if user_id
      'redeemed'
    elsif expires < Time.now
      'expired'
    else
      'valid'
    end
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

  def expiration_progress
    return 0 unless expires
    time_start = expires - SystemSettings.invite_valid_days.days
    ((Time.zone.now - time_start) / (expires - time_start)).round(2)
  end

  def send_sms
    return if phone.nil? || !valid_phone?(phone)
    twilio_client = TwilioClient.new
    join_url = 'https://www.powur.com/next/join/grid/' + id
    message = 'Hey! Jonathan Budd is working on a Game-Changing technology ' \
              'disrupting the $6 trillion energy industry. ' \
              'He thinks you should be involved. Check this out... ' + join_url
    twilio_client.send_message(
      to:   phone,
      from: twilio_client.purchased_numbers.sample,
      body: message)
  end

  class << self
    def generate_code(size = 3)
      SecureRandom.hex(size).upcase
    end
  end

  def max_invites
    return if sponsor.available_invites > 0
    errors.add(:sponsor, :exceeded_max_invites)
  end

  def subtract_from_available_invites
    sponsor.update_column(:available_invites, sponsor.available_invites - 1)
  end

  def increment_available_invites
    sponsor.update_column(:available_invites, sponsor.available_invites + 1)
  end
end

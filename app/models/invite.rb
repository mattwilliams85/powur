require 'valid_email'

class Invite < ActiveRecord::Base
  include NameEmailSearch
  include Phone

  belongs_to :user, class_name: 'User'
  belongs_to :sponsor, class_name: 'User'

  # Validates with https://github.com/hallelujah/valid_email
  validates :email,
    uniqueness: true,
    presence: true,
    email: {
      message: 'This isn\'t a valid email address'
    }
  validates :first_name, :last_name, presence: true
  validates :phone, presence: true, allow_nil: true
  validate :max_invites, on: :create
  validates_with ::Phone::Validator, fields: [:phone]

  after_create :subtract_from_available_invites

  after_destroy :increment_available_invites

  before_validation do
    self.id ||= Invite.generate_code
    self.expires ||= expires_timespan
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def renew
    update_attributes(expires: expires_timespan)
  end

  def accept(params)
    params[:sponsor_id] = sponsor_id
    params[:email] = email

    user = User.new(params)

    latest_agreement = ApplicationAgreement.current
    if latest_agreement && latest_agreement.version != params[:tos]
      user.errors.add(:tos, 'Please read and agree to the latest terms and conditions in the Application and Agreement')
      return user
    end

    if user.save
      Invite.where(email: email).update_all(user_id: user.id)
    end

    user
  end

  def expires_timespan
    SystemSettings.invite_valid_days.days.from_now
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

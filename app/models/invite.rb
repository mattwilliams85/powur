class Invite < ActiveRecord::Base

  belongs_to :invitor, class_name: 'User'
  belongs_to :invitee, class_name: 'User'

  validates :email, :first_name, :last_name, presence: true
  validate :max_invites, on: :create

  before_validation do
    self.id ||= Invite.generate_code
    self.expires ||= expires_timespan
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def renew
    self.update_attributes(expires: expires_timespan)
  end

  def expires_timespan
    PromoterConfig.invite_valid_days.days.from_now
  end

  class << self
    def generate_code
      SecureRandom.hex(3).upcase
    end
  end

  def max_invites
    if invitor.remaining_invites < 1
      errors.add(:invitor, :exceeded_max_invites)
    end
  end

end

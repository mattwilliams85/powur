class Invite < ActiveRecord::Base
  include NameEmailSearch

  belongs_to :user, class_name: 'User'
  belongs_to :sponsor, class_name: 'User'

  validates :email, :first_name, :last_name, presence: true
  validates :phone, presence: true, allow_nil: true
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

  def accept(params)
    params[:sponsor_id] = self.sponsor_id

    user = User.create!(params)
    Invite.where(email: self.email).update_all(user_id: user.id)
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
    if sponsor.remaining_invites < 1
      errors.add(:sponsor, :exceeded_max_invites)
    end
  end

end

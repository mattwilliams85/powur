module UserInvites
  extend ActiveSupport::Concern

  included do
    has_many :invites, foreign_key: 'sponsor_id'

    belongs_to :sponsor, class_name: 'User'
    has_many :distributors, class_name: 'User', foreign_key: 'sponsor_id'
  end

  def remaining_invites
    SystemSettings.max_invites - active_invites.count
  end

  def active_invites
    invites.where(user_id: nil)
  end

  def create_invite(params)
    invite = self.invites.create!(params)
    send_invite(invite)

    invite
  end

  def send_invite(invite)
    PromoterMailer.invitation(invite).deliver
  end

end
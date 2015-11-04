module UserInvites
  extend ActiveSupport::Concern

  included do
    has_many :invites, foreign_key: 'sponsor_id'
    belongs_to :sponsor, class_name: 'User'
    has_many :distributors, class_name: 'User', foreign_key: 'sponsor_id'
  end

  def lifetime_invites_count
    invites.count
  end

  def open_invites_count
    invites.pending.count
  end

  def redeemed_invites_count
    invites.redeemed.count
  end

  def expired_invites_count
    invites.expired.count
  end

  # Create/Send Methods
  def create_invite(params)
    invite = invites.create!(params)
    send_invite(invite) if invite.email?

    invite
  end

  def send_invite(invite)
    PromoterMailer.grid_invite(invite).deliver_later
  end
end

module UserInvites
  extend ActiveSupport::Concern

  included do
    has_many :invites, foreign_key: 'sponsor_id'
    belongs_to :sponsor, class_name: 'User'
    has_many :distributors, class_name: 'User', foreign_key: 'sponsor_id'
  end

  def lifetime_invites_count
    self.available_invites + invites.count
  end

  def open_invites_count
    invites.where('user_id is null').count
  end

  def redeemed_invites_count
    invites.where('user_id is not null').count
  end

  def expired_invites_count
    invites.where(["expires < ?", Time.now]).count
  end

  # Active, non-redeemed invites
  def open_invites
    invites.where(user_id: nil)
  end

  # Expired active, non-redeemed invites
  def expired_invites
    invites.where(["expires < ?", Time.now])
  end

  # Redeemed invites
  def redeemed_invites
    invites.where("user_id is not null")
  end

  # Create/Send Methods
  def create_invite(params)
    invite = invites.create!(params)
    send_invite(invite)

    invite
  end

  def send_invite(invite)
    PromoterMailer.invitation(invite).deliver_later
  end
end

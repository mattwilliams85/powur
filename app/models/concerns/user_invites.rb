module UserInvites
  extend ActiveSupport::Concern

  included do
    has_many :invites, foreign_key: 'sponsor_id'
    belongs_to :sponsor, class_name: 'User'
    has_many :distributors, class_name: 'User', foreign_key: 'sponsor_id'
  end

  # All invites ever awarded (data in user.profile["awarded_invites"]); returns an integer
  def awarded_invites
    if profile && profile["awarded_invites"]
      profile["awarded_invites"].to_i
    else
      0
    end
  end

  # Awarded minus open; returns an integer
  def available_invites
    if awarded_invites
      awarded_invites - open_invites.length
    else
      0
    end
  end

  # Active, non-redeemed invites
  def open_invites
    invites.where(user_id: nil)
  end

  # Expired active, non-redeemed invites
  def expired_invites
    invites.where(["expires < ?", Time.now])
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

module UserInvite
  extend ActiveSupport::Concern

  included do
    has_many :invites, foreign_key: 'invitor_id'
  end

  def remaining_invites
    PromoterConfig.max_invites - active_invites.count
  end

  def active_invites
    invites.where(invitee_id: nil)
  end

  def create_invite(params)
    invite = self.invites.create!(params)
    send_invite(invite)

    invite
  end

  def send_invite(invite)
    PromoterMailer.invitation(invite).deliver
  end

  def add_invited_user(params)
    params[:invitor_id] = self.id

    User.create!(params)
  end

end
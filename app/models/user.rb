class User < ActiveRecord::Base
  include UserSecurity

  has_many :invites, foreign_key: 'invitor_id'

  validates :email, email: true, presence: true
  validates_presence_of :encrypted_password, on: :create
  validates_presence_of :first_name, :last_name, :phone, :zip

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
    PromoterMailer.invitation(invite)
  end

end

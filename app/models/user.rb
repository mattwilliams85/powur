class User < ActiveRecord::Base
  include UserSecurity

  has_many :invites, foreign_key: 'invitor_id'

  validates :email, email: true, presence: true

  def send_invite(params)
    invite = self.invites.create!(params)
    PromoterMailer.invitation(invite)

    invite
  end

end

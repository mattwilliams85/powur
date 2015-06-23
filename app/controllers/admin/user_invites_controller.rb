module Admin
  class UserInvitesController < InvitesController
    before_action :fetch_user
    before_action :fetch_invite, only: [ :resend, :destroy ]

    sort created_at: { created_at: :asc }

    def resend
      @invite.renew
      current_user.send_invite(@invite)

      @invites = @user.invites

      render 'index'
    end

    def destroy
      @invite.destroy!

      @invites =  @user.invites

      render 'index'
    end

    private

    def fetch_invite
      @invite = Invite.find(params[:id])
    end
  end
end

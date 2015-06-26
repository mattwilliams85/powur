module Admin
  class UserInvitesController < InvitesController
    before_action :fetch_user
    before_action :fetch_invite, only: [ :resend, :destroy ]

    sort created_at: { created_at: :asc }

    def award
      @user.available_invites = award_params
      @user.save!

      render 'award'
    end

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

    def award_params
      params.require(:invites)
    end
  end
end

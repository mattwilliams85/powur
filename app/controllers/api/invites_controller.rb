module Api
  class InvitesController < ApiController
    include InvitesActions

    helper_method :invite_path, :resend_invite_path

    private

    def controller_path
      'auth/invites'
    end

    def invite_path(invite)
      api_invite_path(v: params[:v], id: invite)
    end

    def resend_invite_path(invite)
      resend_api_invite_path(v: params[:v], id: invite)
    end
  end
end

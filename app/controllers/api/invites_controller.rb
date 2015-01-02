module Api
  class InvitesController < ApiController
    include InvitesActions

    helper_method :invite_path, :resend_invite_path

    private

    def list_query
      current_user.invites.order(created_at: :desc)
    end

    def invite_path(invite)
      api_invite_path(v: params[:v], id: invite)
    end

    def resend_invite_path(invite)
      resend_api_invite_path(v: params[:v], id: invite)
    end

    class << self
      def controller_path
        'auth/invites'
      end
    end
  end
end

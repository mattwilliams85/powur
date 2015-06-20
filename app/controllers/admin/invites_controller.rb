module Admin
  class InvitesController < AdminController
    page max_limit: 25
    sort user_id: { id: :asc }

    def index
      respond_to do |format|
        format.html
        format.json do
          @invites = apply_list_query_options(Invite)
        end
      end
    end

    def show
      @invite = Invite.find(params[:id])
    end
  end
end

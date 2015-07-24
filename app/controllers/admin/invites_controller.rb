module Admin
  class InvitesController < AdminController
    page max_limit: 25
    sort user_id: { id: :asc }

    def index
      @invites = apply_list_query_options(@user.invites)
    end

    def show
      @invite = Invite.find(params[:id])
    end
  end
end

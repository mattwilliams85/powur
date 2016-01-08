module Admin
  class InvitesController < AdminController
    before_action :fetch_user, only: [ :index ]

    page
    sort id_desc: { id: :desc },
         id_asc:  { id: :asc }
    filter :pending, scope_opts: { type: :boolean }

    def index
      scope = @user ? @user.sent_invites : Invite.all
      scope = scope.merge(Invite.search(params[:search])) if params[:search]
      @invites = apply_list_query_options(scope)
    end

    private

    def fetch_user
      params[:user_id] = params[:admin_user_id] if params[:admin_user_id]
      super
    end
  end
end

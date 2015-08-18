module Admin
  class InvitesController < AdminController
    page
    sort id_desc: { id: :desc },
         id_asc:  { id: :asc }
    filter :pending, scope_opts: { type: :boolean }

    def index
      @invites = apply_list_query_options(Invite)
    end
  end
end

module Admin
  class UserInvitesController < InvitesController
    before_action :fetch_user
  end
end

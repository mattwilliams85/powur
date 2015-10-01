module Anon
  class ProductInvitesController < AnonController
    before_action :fetch_invite, only: [ :update ]

    def update
      # TODO: not sure yet,
      # what we're going to do when users accept ProductInvite
    end

    private

    def fetch_invite
      @invite = ProductInvite.find_by(id: params[:id])
      not_found!(:product_invite) unless @invite
    end
  end
end

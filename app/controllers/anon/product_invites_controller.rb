module Anon
  class ProductInvitesController < AnonController
    before_action :fetch_customer, only: [ :update ]

    def update
      render json: { coming: 'soon' }
    end

    private

    def fetch_invite
      @customer = Customer.find_by(code: params[:id])
      not_found!(:product_invite) unless @customer
    end
  end
end

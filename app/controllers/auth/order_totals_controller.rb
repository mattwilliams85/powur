module Auth

  class OrderTotalsController < AuthController

    def index
      @order_totals = page!(
        @order_totals.includes(:product, :user).references(:product, :user))
    end

  end

end

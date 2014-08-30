module Admin

  class OrderTotalsController < AdminController

    def index
      @order_totals = sort_and_page(
        @order_totals.includes(:product, :user).references(:product, :user))
    end

  end

end

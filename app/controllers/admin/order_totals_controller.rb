module Admin

  class OrderTotalsController < AdminController

    def index
      @order_totals = apply_list_query_options(
        @order_totals.includes(:product, :user).references(:product, :user))
    end

  end

end

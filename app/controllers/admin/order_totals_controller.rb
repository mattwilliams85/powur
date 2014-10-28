module Admin
  class OrderTotalsController < AdminController
    helper OrderTotalsJson

    def index
      product_totals = @order_totals.product_totals
      @totals = product_totals_hash(product_totals)

      @order_totals = apply_list_query_options(
        @order_totals.includes(:product, :user).references(:product, :user))
    end
  end
end

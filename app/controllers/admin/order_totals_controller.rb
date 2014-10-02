module Admin

  class OrderTotalsController < AdminController

    def index
      product_totals = @order_totals.product_totals
      @totals = product_totals.map do |product_total|
        [ [ { name:   "#{product_total.attributes['name']} - Personal Total",
              value:  product_total.attributes['personal_total'] } ],
          [ { name:   "#{product_total.attributes['name']} - Group Total",
              value:  product_total.attributes['group_total'] } ] ]
      end
      @totals.flatten!

      @order_totals = apply_list_query_options(
        @order_totals.includes(:product, :user).references(:product, :user))
    end

  end

end

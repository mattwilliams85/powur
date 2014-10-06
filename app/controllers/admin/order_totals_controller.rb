module Admin
  class OrderTotalsController < AdminController
    def index
      product_totals = @order_totals.product_totals
      @totals = product_totals.map do |pt|
        personal_totals = {
          id:    :personal_order,
          title: t('totals.personal_order', product: pt.attributes['name']),
          type:  :integer,
          value: pt.attributes['personal_total'] }
        group_totals = {
          id:    :group_order,
          title: t('totals.group_order', product: pt.attributes['name']),
          type:  :integer,
          value: pt.attributes['group_total'] }
        [ personal_totals, group_totals ]
      end
      @totals.flatten!

      @order_totals = apply_list_query_options(
        @order_totals.includes(:product, :user).references(:product, :user))
    end
  end
end

class AdminController < AuthController
  layout 'admin'
  before_action :verify_admin

  protected

  def product_totals_hash(product_totals)
    product_totals.map do |pt|
      { id:    :product_orders,
        title: t('totals.product_orders', product: pt.attributes['name']),
        type:  :integer,
        value: pt.personal }
    end
  end
end

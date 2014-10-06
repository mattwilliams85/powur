class AdminController < AuthController
  include BonusJSON
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

  private

  def verify_admin
    redirect_to(dashboard_url) unless current_user.has_role?(:admin)
  end
end

module Admin
  class OrderBonusPaymentsController < BonusPaymentsController
    before_action :fetch_order

    sort bonus: 'bonuses.id'

    private

    def fetch_order
      order = Order.find(params[:order_id].to_i)
      @bonus_payments = order.bonus_payments
      @bonus_payments_path = order_bonus_payments_path(order)
    end
  end
end

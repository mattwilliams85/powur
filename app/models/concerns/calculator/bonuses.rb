module Calculator
  module Bonuses
    extend ActiveSupport::Concern

    def process_order_bonuses(order, use_rank_at)
      bonuses = bonuses_for(order.product_id, use_rank_at)
      bonuses.each do |bonus|
        bonus.create_payments!(order, self)
      end
    end

    def process_at_sale_rank_bonuses!(order)
      process_order_bonuses(order, :sale)
    end

    def process_at_pay_period_end_rank_bonuses!
      orders.each { |order| process_order_bonuses(order, :pay_period_end) }
    end
  end
end

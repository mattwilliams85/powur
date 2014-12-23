module Calculator
  module OrderTotals
    extend ActiveSupport::Concern

    def process_order_totals!(order) # rubocop:disable Metrics/AbcSize
      totals =  find_order_total(order.user_id, order.product_id)
      if totals
        totals.update_columns(
          personal:          totals.personal + order.quantity,
          group:             totals.group + order.quantity,
          personal_lifetime: totals.personal_lifetime + order.quantity,
          group_lifetime:    totals.group_lifetime + order.quantity)
      else
        totals = new_order_total(order)
      end

      increment_upline_totals(order)
      totals
    end

    def increment_upline_totals(order) # rubocop:disable Metrics/AbcSize
      missing = order.user.parent_ids - update_existing_upline(order)

      missing.each do |user_id|
        pl = find_personal_lifetime(user_id, order.product_id)
        gl = find_group_lifetime(user_id, order.product_id)

        order_totals.create!(
          user_id:           user_id,
          product_id:        order.product_id,
          personal:          0,
          group:             order.quantity,
          personal_lifetime: pl ? pl.quantity : 0,
          group_lifetime:    gl ? gl.quantity + order.quantity : order.quantity)
      end
    end

    private

    def update_existing_upline(order) # rubocop:disable Metrics/AbcSize
      user_ids = order.user.parent_ids
      upline_group_totals = order_totals.select do |ot|
        user_ids.include?(ot.user_id) && ot.product_id == order.product_id
      end

      upline_group_totals.each do |gt|
        gt.update_columns(
          group:          gt.group + order.quantity,
          group_lifetime: gt.group_lifetime + order.quantity)
      end

      upline_group_totals.map(&:user_id)
    end
  end
end

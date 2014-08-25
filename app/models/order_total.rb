class OrderTotal < ActiveRecord::Base

  belongs_to :pay_period
  belongs_to :user
  belongs_to :product

  class << self
    def generate_for_pay_period!(pay_period)
      first_order = Order.all_time_first or raise "No generation without first order"

      group_totals = pay_period.group_order_totals
      group_lifetime_totals = Order.
        group_totals(first_order.order_date, pay_period.end_date)

      personal_totals = pay_period.personal_order_totals
      personal_lifetime_totals = Order.
        personal_totals(first_order.order_date, pay_period.end_date).entries

      records = group_totals.map do |group_total|
        group_lifetime_total = group_lifetime_totals.find do |total|
          total.user_id == group_total.user_id && 
            total.product_id == group_total.product_id
        end
        attrs = { 
          pay_period_id:  pay_period.id,
          user_id:        group_total.user_id,
          product_id:     group_total.product_id,
          group:          group_total.quantity,
          group_lifetime: group_lifetime_total.quantity }

        { personal:          personal_totals,
          personal_lifetime: personal_lifetime_totals }.each do |key, list|
          total = list.find do |i|
            i.user_id == group_total.user_id && i.product_id == group_total.product_id
          end
          attrs[key] = total.quantity if total
        end

        attrs
      end

      self.create!(records)
    end

  end

end

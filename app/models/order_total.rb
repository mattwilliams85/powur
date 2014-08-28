class OrderTotal < ActiveRecord::Base

  belongs_to :pay_period
  belongs_to :user
  belongs_to :product

  def user_order_totals
  end

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

      group_sales_not_in_pay_period = group_lifetime_totals.select do |total|
        !records.any? { |record| record[:user_id] == total.user_id }
      end

      records += group_sales_not_in_pay_period.map do |group_total|
        attrs = {
          pay_period_id:  pay_period.id,
          user_id:        group_total.user_id,
          product_id:     group_total.product_id,
          personal:       0,
          group:          0,
          group_lifetime: group_total.quantity }
        total = personal_lifetime_totals.find do |t|
          t.user_id == group_total.user_id &&
            t.product_id && group_total.product_id
        end
        attrs[:personal_lifetime] = total.quantity if total
        attrs
      end

      self.create!(records)
    end

  end

end

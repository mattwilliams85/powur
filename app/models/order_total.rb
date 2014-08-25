class OrderTotal < ActiveRecord::Base

  belongs_to :pay_period
  belongs_to :user
  belongs_to :product

  class << self
    def generate_for_pay_period!(pay_period)
      # generate_personal_sales_for_pay_period!(pay_period)
      # generate_group_sales_for_pay_period!(pay_period)

      group_totals = Order.
        group_totals(pay_period.start_date, pay_period.end_date)
      personal_totals = Order.
        personal_totals(pay_period.start_date, pay_period.end_date).entries

      records = group_totals.map do |group_total|
        attrs = { 
          pay_period_id:  pay_period.id,
          user_id:        group_total.user_id,
          product_id:     group_total.product_id,
          group_total:    group_total.quantity }
        personal_total = personal_totals.find do |total|
          total.user_id == group_total.user_id && 
            total.product_id == group_total.product_id
        end
        attrs[:personal_total] = personal_total.quantity if personal_total
        attrs
      end

      self.create!(records)

    end

    def generate_group_sales_for_pay_period!(pay_period)
      group_totals = Order.group_totals(pay_period.start_date, pay_period.end_date)
      records = group_totals.map do |total|
        { sales_type:     :group_sales,
          pay_period_id:  pay_period.id,
          user_id:        total.user_id,
          product_id:     total.product_id,
          quantity:       total.quantity }
      end
      self.create!(records)
    end

    def generate_personal_sales_for_pay_period!(pay_period)
      personal_totals = Order.personal_totals(pay_period.start_date, pay_period.end_date)
      records = personal_totals.map do |total|
        { sales_type:     :personal_sales,
          pay_period_id:  pay_period.id,
          user_id:        total.user_id,
          product_id:     total.product_id,
          quantity:       total.quantity }
      end
      self.create!(records)
    end

  end

end

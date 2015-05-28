class OrderTotal < ActiveRecord::Base
  belongs_to :pay_period
  belongs_to :user
  belongs_to :product

  scope :user_product, ->(user_id, product_id) {
    where(user_id: user_id, product_id: product_id)
  }

  PRODUCT_TOTALS_SELECT = '
    product_id, name,
    sum(personal) personal'
  scope :product_totals, lambda {
    select(PRODUCT_TOTALS_SELECT).joins(:product).group(:product_id, :name)
  }

  class << self
    def user_current(user, product)
      pay_period_id = MonthlyPayPeriod.current.id
      existing = user_product(user.id, product.id)
        .where(pay_period_id: pay_period_id).first
      return existing if existing

      
    end
  end
end

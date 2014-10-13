class OrderTotal < ActiveRecord::Base
  belongs_to :pay_period
  belongs_to :user
  belongs_to :product

  PRODUCT_TOTALS_SELECT = '
    product_id, name,
    sum(personal) personal'
  scope :product_totals, lambda {
    select(PRODUCT_TOTALS_SELECT).joins(:product).group(:product_id, :name)
  }
end

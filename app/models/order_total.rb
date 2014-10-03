class OrderTotal < ActiveRecord::Base

  belongs_to :pay_period
  belongs_to :user
  belongs_to :product

  scope :product_totals, ->{
    select('product_id, name, sum(personal) personal_total, sum("group") group_total').
    joins(:product).group(:product_id, :name) }

  class << self
  end

end

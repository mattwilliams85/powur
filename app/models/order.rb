class Order < ActiveRecord::Base

  enum status: { ordered: 1, shipped: 2, cancelled: 3, refunded: 4 }

  belongs_to :bonus_plan
  belongs_to :product
  belongs_to :user
  belongs_to :quote
end

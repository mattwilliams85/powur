class Order < ActiveRecord::Base

  enum status: { pending: 1, shipped: 2, cancelled: 3, refunded: 4 }

  belongs_to :bonus_plan
  belongs_to :product
  belongs_to :user
  belongs_to :customer
  belongs_to :quote

  add_search :user, :customer, [ :user, :customer ]
  
end

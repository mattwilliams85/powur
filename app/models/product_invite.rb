class ProductInvite < ActiveRecord::Base
  belongs_to :product
  belongs_to :customer
  belongs_to :user

  validates :product_id, :customer_id, :user_id, presence: true

  enum status: [ :sent, :opened, :completed ]
end

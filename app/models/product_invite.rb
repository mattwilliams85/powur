class ProductInvite < ActiveRecord::Base
  belongs_to :product
  belongs_to :customer
  belongs_to :user

  enum status: [ :sent, :opened, :completed ]
end

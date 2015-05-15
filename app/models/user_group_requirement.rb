class UserGroupRequirement < ActiveRecord::Base
  belongs_to :user_group
  belongs_to :product

  enum event_type: { enrollment: 1, purchase: 2, sale: 3 }

  validates_presence_of :user_group_id, :product_id, :event_type, :quantity
end

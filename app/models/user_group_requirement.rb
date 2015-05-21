class UserGroupRequirement < ActiveRecord::Base
  belongs_to :user_group
  belongs_to :product

  enum time_span: { monthly: 1, lifetime: 2 }
  enum event_type: { course_completion: 1, personal_sales: 2, group_sales: 3 }

  validates_presence_of :user_group_id, :product_id, :event_type, :quantity
end

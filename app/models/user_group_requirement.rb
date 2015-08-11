class UserGroupRequirement < ActiveRecord::Base
  belongs_to :user_group
  belongs_to :product

  enum time_span: { monthly: 1, lifetime: 2 }
  enum event_type: {
    purchase:           1,
    personal_sales:     2,
    grid_sales:        3,
    personal_proposals: 4,
    grid_proposals:    5 }

  validates_presence_of :user_group_id, :product_id, :event_type, :quantity

  def title
    "#{quantity} #{time_span} #{event_type} for #{product.name}"
  end
end

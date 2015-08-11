class RankRequirement < ActiveRecord::Base
  belongs_to :rank
  belongs_to :product

  enum time_span: { monthly: 1, lifetime: 2 }
  enum event_type: {
    purchase:           1,
    personal_sales:     2,
    grid_sales:        3,
    personal_proposals: 4,
    grid_proposals:    5 }

  validates_presence_of :rank_id, :product_id, :event_type, :quantity

  scope :monthly_join, -> { monthly.select(:rank_id).distinct(:rank_id) }

  def title
    "#{quantity} #{time_span} #{event_type} for #{product.name}"
  end
end

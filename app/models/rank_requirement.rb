class RankRequirement < ActiveRecord::Base
  belongs_to :rank
  belongs_to :product

  enum time_span: { monthly: 1, lifetime: 2 }

  validates_presence_of :rank_id, :product_id, :quantity

  scope :monthly_join, -> { monthly.select(:rank_id).distinct(:rank_id) }

  def title
    "#{quantity} #{time_span} #{self.class.name} for #{product.name}"
  end
end

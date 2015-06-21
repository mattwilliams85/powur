class LeadTotals < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  belongs_to :pay_period

  enum status: [ :qualified, :won ]

  class << self
    def hydrate(opts = {})
      Quote
        .select('count(id), user_id, product_id')
        .group(:user_id, :product_id)
        .where()
    end
  end
end

module SalesBonus
  extend ActiveSupport::Concern

  included do
    belongs_to :product
    enum schedule: { weekly: 1, pay_period: 2 }

    validates_presence_of :product_id, :amounts
  end
end
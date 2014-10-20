module SalesBonus
  extend ActiveSupport::Concern

  included do
    belongs_to :product

    validates_presence_of :product_id, :amounts
  end
end

class SalesQualification < Qualification

  enum period: { pay_period: 1, lifetime: 2 }

  belongs_to :product

  validates_presence_of :product_id, :quantity, :period

end
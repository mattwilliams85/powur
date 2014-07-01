class SalesQualification < Qualification

  enum period: { pay_period: 1, lifetime: 2 }

  belongs_to :product

end
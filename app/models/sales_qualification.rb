class SalesQualification < Qualification

  validates_presence_of :product_id, :quantity, :time_period

  def met?(totals)
    self.pay_period? ?
      totals.personal >= quantity :
      totals.personal_lifetime >= quantity
  end

end

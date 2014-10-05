class SalesQualification < Qualification
  validates_presence_of :product_id, :quantity, :time_period

  def met?(totals)
    value = pay_period? ? totals.personal : totals.personal_lifetime
    value >= quantity
  end
end

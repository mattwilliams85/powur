class SalesQualification < Qualification

  enum period: { lifetime: 1, monthly: 2, weekly: 3 }

  validates_presence_of :product_id, :quantity, :period

  def met?(user_id, pay_period)
    totals = pay_period.order_totals.find do |t|
      t.user_id == user_id && t.product_id == self.product_id
    end
    return false unless totals

    self.pay_period? ? 
      totals.personal >= quantity : 
      totals.personal_lifetime >= quantity
  end

end

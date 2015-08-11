class SellerBonus < Bonus
  def create_payments!(calculator)
    pay_period_id = calculator.pay_period.id
    [ :contracted, :installed ].each do |status|
      calculator.send("#{status}_leads").each do |lead|
        create_lead_payment(lead, pay_period_id)
      end
    end
  end

  def payment_amounts
    bonus_amounts.entries.first.amounts
  end

  def calculate_amount(pay_as_rank)
    payment_amounts[pay_as_rank] * 0.5
  end

  private

  def create_lead_payment(lead, pay_period_id)
    pay_as_rank = lead.user.pay_as_rank(pay_period_id)

    payment = bonus_payments.create!(
      pay_period_id: pay_period_id,
      user_id:       lead.user_id,
      pay_as_rank:   pay_as_rank,
      amount:        calculate_amount(pay_as_rank))

    payment.bonus_payment_leads.create!(lead_id: lead.id)
  end
end

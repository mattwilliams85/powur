class SellerBonus < Bonus
  store_accessor :meta_data,
                 :converted_percent, :contracted_percent, :installed_percent

  def create_payments!(calculator)
    pay_period_id = calculator.pay_period.id
    [ :converted, :contracted, :installed ].each do |status|
      percent = send("#{status}_percent")
      next unless percent
      calculator.send("#{status}_leads").each do |lead|
        create_lead_payment(lead, pay_period_id, status, percent.to_f)
      end
    end
  end

  def payment_amounts
    bonus_amounts.entries.first.amounts
  end

  def calculate_amount(pay_as_rank, percent)
    payment_amounts[pay_as_rank] * percent
  end

  private

  def create_lead_payment(lead, pay_period_id, status, percent)
    pay_as_rank = lead.user.pay_period_rank(pay_period_id)
    amount = calculate_amount(pay_as_rank, percent)

    return unless amount > 0

    payment = bonus_payments.create!(
      pay_period_id: pay_period_id,
      user_id:       lead.user_id,
      pay_as_rank:   pay_as_rank,
      amount:        amount)

    payment.bonus_payment_leads.create!(lead_id: lead.id, status: status)
  end
end

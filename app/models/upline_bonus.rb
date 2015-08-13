class UplineBonus < Bonus
  store_accessor :meta_data, :upline, :first_n, :organic_rank

  def create_payments!(calculator)
    pay_period_id = calculator.pay_period.id

    calculator.converted_leads.each do |lead|
      next if lead.converted_count_at_time > first_n
      create_lead_payment(lead, pay_period_id)
    end
  end

  def sponsor?
    meta_data['upline'] == 'sponsor'
  end

  def payment_amounts
    bonus_amounts.entries.first.amounts
  end

  def calculate_amount(pay_as_rank)
    payment_amounts[pay_as_rank]
  end

  def first_n
    meta_data['first_n'].to_i
  end

  def organic_rank
    meta_data['organic_rank'].to_i
  end

  private

  def find_upline_user(lead)
    sponsor? ? lead.user.sponsor : lead.user.parent
  end

  def create_lead_payment(lead, pay_period_id)
    user = find_upline_user(lead)
    return unless user

    pay_as_rank = user.pay_period_rank(pay_period_id)
    amount = calculate_amount(pay_as_rank)

    return unless amount > 0

    payment = bonus_payments.create!(
      pay_period_id: pay_period_id,
      user_id:       user.id,
      pay_as_rank:   pay_as_rank,
      amount:        amount)

    payment.bonus_payment_leads.create!(lead_id: lead.id, status: :converted)
  end
end

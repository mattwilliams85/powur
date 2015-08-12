class DifferentialBonus < Bonus
  store_accessor :meta_data, :amount, :upline, :nth_proposal

  def create_payments!(calculator)
    if solar_sales_triggered?
      create_solar_sales_payments(calculator)
    else
      create_nth_proposal_payments(calculator)
    end
  end

  def payment_amounts
    bonus_amounts.entries.first.amounts
  end

  def available_amount
    BigDecimal.new(meta_data['amount'])
  end

  def sponsor?
    meta_data['upline'] == 'sponsor'
  end

  def nth_proposal
    meta_data['nth_proposal'].to_i
  end

  def solar_sales_triggered?
    meta_data['nth_proposal'].nil?
  end

  private

  def create_solar_sales_payments(calculator)
    [ :contracted, :installed ].each do |status|
      calculator.send("#{status}_leads").each do |lead|
        create_lead_payments(lead, calculator.pay_period.id, status)
      end
    end
  end

  def create_nth_proposal_payments(calculator)
    calculator.converted_leads.select do |lead|
      next unless lead.converted_count_at_time == nth_proposal
      create_lead_payments(lead, calculator.pay_period.id, :converted)
    end
  end

  def calculate_payment_percent(pay_as_rank, percentage_used)
    return unless pay_as_rank >= min_rank
    user_percent = payment_amounts[pay_as_rank]
    return if percentage_used >= user_percent
    user_percent - percentage_used
  end

  def create_lead_payments(lead, pay_period_id, status)
    upline = user_upline(lead.user)
    return if upline.empty?

    percentage_used = 0.0
    while (user = upline.shift)
      pay_as_rank = user.pay_period_rank(pay_period_id)
      percentage = calculate_payment_percent(pay_as_rank, percentage_used)
      next unless percentage

      payment = bonus_payments.create!(
        pay_period_id: pay_period_id,
        user_id:       user.id,
        pay_as_rank:   pay_as_rank,
        amount:        available_amount * percentage)

      payment.bonus_payment_leads.create!(lead_id: lead.id, status: status)

      percentage_used += percentage
    end
  end

  def min_rank
    payment_amounts.index { |a| a > 0 }
  end

  def user_upline(user)
    sponsor? ? user.sponsor_upline : user.placement_upline
  end
end

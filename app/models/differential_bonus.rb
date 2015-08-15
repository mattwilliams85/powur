class DifferentialBonus < Bonus
  store_accessor :meta_data,
                 :converted_percent, :contracted_percent,
                 :installed_percent, :first_n, :nth_proposal, :upline

  def create_payments!(calculator)
    relevant_lead_statuses.each do |status|
      leads_for_status(calculator, status).each do |lead|
        create_lead_payments(calculator, lead, status)
      end
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

  def first_n
    meta_data['first_n'] && meta_data['first_n'].to_i
  end

  def nth_proposal
    meta_data['nth_proposal'] && meta_data['nth_proposal'].to_i
  end

  private

  def percent_allocated(status)
    meta_data["#{status}_percent"] && meta_data["#{status}_percent"].to_f
  end

  def relevant_lead_statuses
    [ :converted, :contracted, :installed ].select do |status|
      percent_allocated(status) && percent_allocated(status) > 0
    end
  end

  def apply_lead_filters(leads, status)
    if first_n
      leads.select { |l| l.status_totals_at_time(status) <= first_n }
    elsif nth_proposal
      leads.select { |l| l.status_totals_at_time(status) == nth_proposal }
    else
      leads
    end
  end

  def leads_for_status(calculator, status)
    leads = calculator.send("#{status}_leads")
    apply_lead_filters(leads, status)
  end

  def create_solar_sales_payments(calculator)
    [ :contracted, :installed ].each do |status|
      calculator.send("#{status}_leads").each do |lead|
        create_lead_payments(calculator, lead, status)
      end
    end
  end

  def create_nth_proposal_payments(calculator)
    leads = calculator.converted_leads.select do |lead|
      lead.converted_count_at_time == nth_proposal
    end
    leads.each { |lead| create_lead_payments(calculator, lead, :converted) }
  end

  def calculate_payment_percent(pay_as_rank, percentage_used)
    return unless pay_as_rank >= min_rank
    user_percent = payment_amounts[pay_as_rank]
    return if percentage_used >= user_percent
    user_percent - percentage_used
  end

  def create_lead_payments(calculator, lead, status)
    upline = calculator.user_upline(lead.user, sponsor?)
    return if upline.empty?

    percentage_used = 0.0
    while (user = upline.shift)
      pay_as_rank = user.pay_period_rank(calculator.pay_period.id)
      percentage = calculate_payment_percent(pay_as_rank, percentage_used)
      next unless percentage
      amount = available_amount * percentage * percent_allocated(status)

      payment = bonus_payments.create!(
        pay_period_id: calculator.pay_period.id,
        user_id:       user.id,
        pay_as_rank:   pay_as_rank,
        amount:        amount,
        bonus_data:    { percentage: percentage })

      payment.bonus_payment_leads.create!(lead_id: lead.id, status: status)

      percentage_used += percentage
    end
  end

  def min_rank
    payment_amounts.index { |a| a > 0 }
  end
end

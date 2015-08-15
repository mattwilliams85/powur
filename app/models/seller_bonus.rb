class SellerBonus < Bonus
  store_accessor :meta_data,
                 :converted_percent, :contracted_percent,
                 :installed_percent, :first_n

  def create_payments!(calculator)
    relevant_lead_statuses.each do |status|
      leads = calculator.send("#{status}_leads")
      if first_n
        leads = leads.select { |l| l.status_totals_at_time(status) <= first_n }
      end
      leads.each do |lead|
        create_lead_payments(calculator, lead, status)
      end
    end
  end

  def payment_amounts
    bonus_amounts.entries.first.amounts
  end

  def calculate_amount(pay_as_rank, percent)
    payment_amounts[pay_as_rank] * percent
  end

  def first_n
    meta_data['first_n'] && meta_data['first_n'].to_i
  end

  private

  def relevant_lead_statuses
    [ :converted, :contracted, :installed ].select do |status|
      percent = send("#{status}_percent")
      percent && percent.to_f > 0
    end
  end

  def create_lead_payments(calculator, lead, status)
    pay_as_rank = lead.user.pay_period_rank(calculator.pay_period.id)
    percent = send("#{status}_percent").to_f
    amount = calculate_amount(pay_as_rank, percent)

    return unless amount > 0

    payment = bonus_payments.create!(
      pay_period_id: calculator.pay_period.id,
      user_id:       lead.user_id,
      pay_as_rank:   pay_as_rank,
      amount:        amount)

    payment.bonus_payment_leads.create!(lead_id: lead.id, status: status)
  end
end

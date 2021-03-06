class GenerationalBonus < Bonus
  store_accessor :meta_data,
                 :converted_percent, :contracted_percent, :installed_percent,
                 :upline

  def create_payments!(calculator)
    relevant_lead_statuses.each do |status|
      calculator.status_leads(status).each do |lead|
        create_lead_payments(calculator, lead, status)
      end
    end
  end

  def sponsor?
    meta_data['upline'] == 'sponsor'
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

  def user_qualified?(user, bonus_level, pay_period_id)
    user.pay_period_rank(pay_period_id) >= bonus_level.first_rank
  end

  def find_qualified_user(upline, bonus_level, pay_period_id)
    user = nil
    loop do
      user = upline.shift
      break if user.nil?
      if !user.terminated? && user_qualified?(user, bonus_level, pay_period_id)
        break
      end
    end
    user
  end

  def create_lead_payments(calculator, lead, status)
    upline = calculator.user_upline(lead.user, sponsor?)
    bonus_amounts.sort_by(&:level).each do |bonus_level|
      user = find_qualified_user(upline, bonus_level, calculator.pay_period.id)
      break unless user
      pay_as_rank = user.pay_period_rank(calculator.pay_period.id)
      amount = bonus_level.rank_amount(pay_as_rank) *
        send("#{status}_percent").to_f

      payment = bonus_payments.create!(
        pay_period_id: calculator.pay_period.id,
        user_id:       user.id,
        pay_as_rank:   pay_as_rank,
        amount:        amount,
        bonus_data:    { generation: bonus_level.level })

      payment.bonus_payment_leads.create!(
        lead_id: lead.id,
        status:  status)
    end
  end
end

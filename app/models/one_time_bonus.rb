class OneTimeBonus < Bonus
  store_accessor :meta_data, :amount, :end_date, :criteria

  def amount
    BigDecimal.new(meta_data['amount'])
  end

  def end_date
    Date.strptime(meta_data['end_date'])
  end

  def criteria
    @criteria ||= begin
      case meta_data['criteria']
      when 'has_converted_lead'
        Lead.select(:user_id).converted(to: end_date + 1.day)
          .group(:user_id).entries.map(&:user_id)
      end
    end
  end

  def create_payments!
    pay_period_id = WeeklyPayPeriod.current.id
    criteria.each do |user_id|
      bonus_payments.create!(
        pay_period_id: pay_period_id,
        user_id:       user_id,
        amount:        amount)
    end
  end

  def reset
    bonus_payments.destroy_all
  end

  def distribute!
    distribution ||= create_distribution

    payments = bonus_payments.pending.with_ewallets.entries
    distribution_data = payments.map(&:distribution_data)
    distribution_response = distribution.distribute!(distribution_data)

    BonusPayment.where(id: payments.map(&:id)).update_all(
      distribution_id: distribution.id,
      status:          :paid)

    distribution_response
  end
end

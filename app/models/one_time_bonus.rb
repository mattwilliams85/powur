class OneTimeBonus < Bonus
  store_accessor :meta_data, :available_amount, :end_date, :criteria

  def available_amount
    BigDecimal.new(meta_data['available_amount'])
  end

  def end_date
    Date.strptime(meta_data['end_date'])
  end

  def qualified_users
    @qualified_users ||= begin
      case meta_data['criteria']
      when 'has_converted_lead'
        ids = Lead.select(:user_id).converted(to: end_date + 1.day)
          .group(:user_id).entries.map(&:user_id)
        Hash[ ids.map { |id| [ id, 1 ] } ]
      when 'august_contest'
        qualified_leads = Lead
          .converted(pay_period_id: '2015-08')
          .preload(:user)
        ids = {}
        qualified_leads.each do |lead|
          next unless lead.user.partner?
          sponsor = lead.user.sponsor
          if sponsor && !sponsor.breakage_account? && sponsor.partner?
            ids[sponsor.id] ||= 0
            ids[sponsor.id] += 1
          end
          next if lead.user.breakage_account?
          ids[lead.user_id] ||= 0
          ids[lead.user_id] += 1
        end
        ids
      end
    end
  end

  def create_payments!
    pay_period_id = WeeklyPayPeriod.current.id
    qualified_users.each do |user_id, quantity|
      bonus_payments.create!(
        pay_period_id: pay_period_id,
        user_id:       user_id,
        amount:        amount * quantity)
    end
  end

  def reset
    bonus_payments.destroy_all
  end

  def distribute!
    distribution ||= create_distribution

    payments = bonus_payments.pending.preload(:user).entries
    payment_ids = payments.map(&:id)

    BonusPayment.where(id: payment_ids).update_all(
      distribution_id: distribution.id)

    distribution.distribute!(payments)
  end
end

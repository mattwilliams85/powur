class CodedBonus < Bonus
  store_accessor :meta_data,
                 :converted_percent, :contracted_percent,
                 :installed_percent, :first_n, :nth_proposal,
                 :after_purchase, :upline, :include_user, :available_amount

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

  def first_n
    meta_data['first_n'] && meta_data['first_n'].to_i
  end

  def nth_proposal
    meta_data['nth_proposal'] && meta_data['nth_proposal'].to_i
  end

  def after_purchase
    meta_data['after_purchase'] && meta_data['after_purchase'].to_i
  end

  def available_amount
    BigDecimal.new(meta_data['available_amount'])
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

  def apply_lead_filters(leads, status)
    return leads unless first_n || nth_proposal
    leads.select do |lead|
      count = lead.status_count_at_time(status, after_purchase)
      first_n ? (!count.zero? && count <= first_n) : (count == nth_proposal)
    end
  end

  def leads_for_status(calculator, status)
    leads = calculator.status_leads(status)
    if after_purchase
      leads = leads.select do |l|
        purchased_at = l.user.purchased_at(after_purchase)
        purchased_at && purchased_at <= l.status_date(status)
      end
    end

    apply_lead_filters(leads, status)
  end

  def create_lead_payments(calculator, lead, status)
    upline = calculator.user_upline(lead.user, sponsor?)
    return if upline.empty?

    unless lead.user.coded_user_id?
      CodedBonus.calculate_sponsor_codes(lead.user)
    end
    return unless lead.user.coded_user_id?

    pay_as_rank = lead.user.pay_period_rank(calculator.pay_period.id)
    attrs = {
      pay_period_id: calculator.pay_period.id,
      user_id:       lead.user.coded_user_id,
      pay_as_rank:   pay_as_rank }

    attrs[:amount] =
      if first_n || nth_proposal
        lead_number = lead.status_count_at_time(status, after_purchase)
        attrs[:bonus_data] = { lead_number: lead_number }
        payment_amounts[lead_number - 1] * percent_allocated(status)
      else
        payment_amounts[pay_as_rank] * percent_allocated(status)
      end

    payment = bonus_payments.create!(attrs)
    payment.bonus_payment_leads.create!(lead_id: lead.id, status: :converted)
  end

  class << self
    def calculate_sponsor_codes(user)
      return unless user.sponsor_id?

      siblings = User
        .where(sponsor_id: user.sponsor_id)
        .purchased(3)
        .order('product_receipts.purchased_at ASC')
        .pluck(:id)

      sequence = siblings.index(user.id) || return
      if sequence.odd?
        user.update_attributes!(coded_user_id: user.sponsor_id)
        return
      end

      unless user.sponsor.coded_user_id?
        return unless user.sponsor.sponsor_id?
        calculate_sponsor_codes(user.sponsor)
      end

      user.update_attributes!(coded_user_id: user.sponsor.coded_user_id)
    end
  end
end

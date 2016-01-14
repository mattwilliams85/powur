class LeadRequirement < RankRequirement
  enum lead_status: { converted: 1, installed: 2 }

  def requirement_for_label
    team? ? 'Grid' : 'Personal'
  end

  STATUS_LABELS = {
    converted: 'Qualified',
    installed: 'Installs' }
  def title
    "#{requirement_for_label} #{STATUS_LABELS[lead_status]} Leads"
  end

  def progress_for(user_id, pay_period_id = nil)
    pay_period_id ||= MonthlyPayPeriod.current_id
    totals = lead_totals_query(pay_period_id).where(user_id: user_id).first
    totals ? totals.send(lead_totals_quantity_column) : 0
  end

  def user_qualified?(user_id, pay_period_id)
    query = qualified_lead_totals(pay_period_id).where(user_id: user_id)
    return query.exists? unless leg_count?
    result = query.first
    !result.nil? && result.qualified_team_legs(quantity) > leg_count
  end

  def qualified_user_ids(pay_period_id: nil,
                         exclude_users: nil,
                         include_users: nil)
    query = qualified_lead_totals(pay_period_id)
    query = query.exclude_users(exclude_users) if exclude_users
    query = query.include_users(include_users) if include_users
    return query.pluck(:user_id) unless leg_count?

    query.entries.select do |lead_totals|
      lead_totals.qualified_team_legs(quantity) > leg_count
    end.map(&:user_id)
  end

  def max_leg?
    !max_leg.nil? && max_leg > 0
  end

  def smaller_legs_need
    ((1 - (max_leg / 100.0)) * quantity).ceil
  end

  def max_leg_met?(amount)
    amount >= smaller_legs_amount_needed
  end

  def leg_count?
    super && leg_count > 1
  end

  def lead_totals_quantity_column
    name = team? ? 'team' : 'personal'
    name += '_lifetime' unless monthly?
    name
  end

  private

  def lead_totals_query(pay_period_id)
    LeadTotals.send(lead_status).where(pay_period_id: pay_period_id)
  end

  def qualified_lead_totals(pay_period_id)
    query = LeadTotals
      .send(lead_status)
      .where(pay_period_id: pay_period_id)
      .where("\"#{lead_totals_quantity_column}\" >= ?", quantity)
    return query unless team?

    query = query.where('smaller_legs >= ?', smaller_legs_need) if max_leg?
    query
  end
end

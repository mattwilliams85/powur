class LeadRequirement < RankRequirement
  def progress_for(user_id, pay_period_id)
    totals = qualified_lead_totals(pay_period_id)
      .where(user_id: user_id).first
    totals ? totals.send(lead_totals_quantity_column) : 0
  end

  def user_qualified?(user_id, pay_period_id)
    qualified_lead_totals(pay_period_id).where(user_id: user_id).exists?
  end

  def qualified_user_ids(pay_period_id: nil,
                         exclude_users: nil,
                         include_users: nil)
    query = qualified_lead_totals(pay_period_id)
    query = query.exclude_users(exclude_users) if exclude_users
    query = query.include_users(include_users) if include_users
    query.pluck(:user_id)
  end

  def max_leg?
    !max_leg.nil? && max_leg > 0
  end

  def smaller_legs_amount_needed
    ((1 - (max_leg / 100.0)) * quantity).ceil
  end

  def max_leg_met?(amount)
    amount >= smaller_legs_amount_needed
  end

  def lead_totals_quantity_column
    name = personal? ? 'personal' : 'team'
    name += '_lifetime' unless monthly?
    name
  end

  private

  def personal?
    personal_sales? || personal_proposals?
  end

  def proposals?
    personal_proposals? || group_proposals?
  end

  def lead_status
    proposals? ? :converted : :contracted
  end

  def lead_totals_query(pay_period_id)
    LeadTotals.send(lead_status).where(pay_period_id: pay_period_id)
  end

  def qualified_lead_totals(pay_period_id)
    query = lead_totals_query(pay_period_id)
      .where("\"#{lead_totals_quantity_column}\" >= ?", quantity)
    if max_leg?
      query = query.where('smaller_legs >= ?', smaller_legs_amount_needed)
    end
    query
  end
end

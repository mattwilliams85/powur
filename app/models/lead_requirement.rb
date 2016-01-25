class LeadRequirement < RankRequirement
  enum lead_status: { converted: 1, installed: 2 }

  def requirement_for_label
    team? ? 'Team' : 'Your'
  end

  def title
    "#{requirement_for_label} Leads"
  end

  def progress_for(user_id, month = nil)
    month ||= MonthlyPayPeriod.current_id
    totals = UserTotals.where(id: user_id).first
    totals && totals.progress_for_requirement(self, month)
  end

  def user_qualified?(user_id, pay_period_id)
    qualified_lead_totals(pay_period_id).where(id: user_id).exists?
  end

  def qualified_user_ids(pay_period_id: nil,
                         exclude_users: nil,
                         include_users: nil)
    query = qualified_lead_totals(pay_period_id)
    query = query.exclude_users(exclude_users) if exclude_users
    query = query.include_users(include_users) if include_users
    query.pluck(:id)
  rescue => e
    binding.pry
    fail e
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

  private

  def query_scope
    if team?
      if leg_count?
        :lead_leg_count_met
      else
        monthly? ? :monthly_team_count_met : :lifetime_team_count_met
      end
    else
      :quantity_met
    end
  end

  def query_args(month)
    args = { status: lead_status, quantity: quantity }
    args[:month] = month if monthly?
    args[:leg_count] = leg_count if leg_count?
    args
  end

  def qualified_lead_totals(month)
    UserTotals.send(query_scope, query_args(month))
  end
end

class UserGroupRequirement < ActiveRecord::Base
  belongs_to :user_group
  belongs_to :product

  enum time_span: { monthly: 1, lifetime: 2 }
  enum event_type: {
    purchase:           1,
    personal_sales:     2,
    group_sales:        3,
    personal_proposals: 4,
    group_proposals:    5 }

  validates_presence_of :user_group_id, :product_id, :event_type, :quantity

  def title
    "#{quantity} #{time_span} #{event_type} for #{product.name}"
  end

  def smaller_legs_amount_needed
    ((1 - (max_leg / 100.0)) * quantity).ceil
  end

  def qualified_user_ids(pay_period_id)
    purchase? ? purchased_user_ids : sales_met_user_ids(pay_period_id)
  end

  def user_qualified?(user_id)
    purchase? ? user_purchased?(user_id) : user_met_sales?(user_id)
  end

  def progress_for(user)
    if purchase?
      (user_qualified?(user) ? 1 : 0)
    else
      sales_progress_for(user)
    end
  end

  def lead_totals_quantity_column
    name = personal_sales? ? 'personal' : 'team'
    name += '_lifetime' unless monthly?
    name
  end

  private

  def sales_progress_for(user)
    query =
      if personal?
        Lead.where(user_id: user.id)
      else
        Lead.joins(:user).merge(User.all_team(user.id))
      end
    opts = { pay_period_id: monthly? ? current_pp_id : nil }
    (proposals? ? query.converted(opts) : query.contracted(opts)).count
  end

  def current_pp_id
    MonthlyPayPeriod.current.id
  end

  def personal?
    personal_sales? || personal_proposals?
  end

  def proposals?
    personal_proposals? || group_proposals?
  end

  def purchases
    ProductReceipt.where(product_id: product_id)
  end

  def qualified_lead_totals(pay_period_id)
    status = LeadTotals.statuses[proposals? ? :converted : :contracted]
    lead_totals = LeadTotals
      .where(pay_period_id: pay_period_id)
      .where(status: status)
      .where("\"#{lead_totals_quantity_column}\" >= ?", quantity)
      .entries
    if max_leg? && max_leg > 0
      lead_totals.reject! { |lt| !lt.requirement_met?(req) }
    end
    lead_totals
  end

  def purchased_user_ids
    purchases.pluck(:user_id)
  end

  def user_purchased?(user_id)
    purchases.where(user_id: user_id).exists?
  end

  def sales_met_user_ids(pay_period_id)
    qualified_lead_totals(pay_period_id).map(&:user_id)
  end

  def condition_user_query(user_id)
    if personal?
      Lead.where(user_id: id)
    else
      Lead.joins(:user).merge(User.with_ancestor(user_id))
    end
  end

  def condition_met_query(user_id)
    query = condition_user_query(user_id)
    query = proposals? ? query.proposals : query.contract
    if monthly?
      date_field = proposals? ? 'converted_at' : 'contracted_at'
      query = query.where("#{date_field} >= ?", Date.today.beginning_of_month)
    end
    query
  end

  def user_met_sales?(user_id)
    condition_met_query(user_id).count > quantity
  end
end

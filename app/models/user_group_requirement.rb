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

  def qualified_user_ids
    purchase? ? purchased_user_ids : sales_met_user_ids
  end

  def user_qualified?(user_id)
    purchase? ? user_purchased?(user_id) : user_met_sales?(user_id)
  end

  private

  def personal?
    personal_sales? || personal_proposals?
  end

  def proposals?
    personal_proposals? || group_proposals?
  end

  def purchases
    ProductReceipt.where(product_id: product_id)
  end

  def order_total_quantity_column
    name = personal_sales? ? 'personal' : 'group'
    name += '_lifetime' unless monthly?
    name
  end

  def qualified_order_totals
    @order_totals ||= begin
      period_id = MonthlyPayPeriod.current.id
      OrderTotal.where(product_id:    product_id,
                       pay_period_id: period_id)
        .where("\"#{order_total_quantity_column}\" >= ?", quantity)
    end
  end

  def purchased_user_ids
    purchases.pluck(:user_id)
  end

  def user_purchased?(user_id)
    purchases.where(user_id: user_id).exists?
  end

  def sales_met_user_ids
    qualified_order_totals.pluck(:user_id)
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

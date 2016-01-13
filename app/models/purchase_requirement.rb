class PurchaseRequirement < RankRequirement
  def progress_for(user_id, pay_period_id = nil)
    pay_period_id ||= MonthlyPayPeriod.current_id
    user_qualified?(user_id, pay_period_id) ? 1 : 0
  end

  def user_qualified?(user_id, pay_period_id)
    pay_period_purchases(pay_period_id).where(user_id: user_id).exists?
  end

  def qualified_user_ids(pay_period_id: nil,
                         exclude_users: nil,
                         include_users: nil)
    query = pay_period_purchases(pay_period_id)
    query = query.exclude_users(exclude_users) if exclude_users
    query = query.include_users(include_users) if include_users
    query.pluck(:user_id)
  end

  private

  def purchases
    @purchases ||= ProductReceipt.where(
      product_id: product_id, refunded_at: nil)
  end

  def pay_period_purchases(pay_period_id)
    end_date = MonthlyPayPeriod.end_date_from_id(pay_period_id)
    purchases.where('product_receipts.purchased_at < ?', end_date + 1.day)
  end
end

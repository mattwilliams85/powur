class MatchingBonus < Bonus
  store_accessor :meta_data, :matching_bonus_id, :matching_percentage

  def create_payments!(calculator)
    results = generate_bonus_payments(calculator)
    results.values.each do |result|
      result.save! if result.is_a?(BonusPayment)
    end
    results
  end

  def report_payments(calculator)
    generate_bonus_payments(calculator)
  end

  def generate_bonus_payments(calculator)
    user_totals = fetch_user_totals(calculator.pay_period.id)
    sponsors = fetch_qualified_sponsors(user_totals)

    user_totals.each_with_object({}) do |user, matches|
      matches[user] = try_create_payment(calculator, user, sponsors)
    end
  end

  def matching_bonus_id
    meta_data['matching_bonus_id'].to_i
  end

  def matching_bonus
    @matching_bonus ||= Bonus.find(matching_bonus_id)
  end

  def matching_percentage
    meta_data['matching_percentage'].to_f
  end

  private

  def matched_totals(pay_period_id)
    matching_bonus
      .bonus_payments
      .select(:user_id, 'sum(amount) amount')
      .where(pay_period_id: pay_period_id)
      .group(:user_id)
  end

  def fetch_user_totals(pay_period_id)
    join = matched_totals(pay_period_id)
    User
      .select('users.*', 't.amount bonus_amount')
      .joins("inner join (#{join.to_sql}) t ON t.user_id = id")
  end

  def fetch_qualified_sponsors(matched_users)
    sponsor_ids = matched_users.map(&:sponsor_id).compact.uniq
    sponsors = User.where(id: sponsor_ids).entries

    sponsors.each_with_object({}) do |sponsor, qualified|
      next unless matching_bonus.eligible_for_code?(sponsor)
      qualified[sponsor.id] = sponsor
    end
  end

  def try_create_payment(calculator, user, sponsors)
    return :no_sponsor unless user.sponsor_id?
    sponsor = sponsors[user.sponsor_id]
    return :unqualified_sponsor if sponsor.nil?

    bonus_payments.new(
      pay_period_id: calculator.pay_period.id,
      user_id:       sponsor.id,
      amount:        user.bonus_amount * matching_percentage)
  end
end

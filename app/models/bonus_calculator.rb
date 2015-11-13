class BonusCalculator
  attr_reader :pay_period

  def initialize(pay_period)
    if pay_period.is_a?(String)
      pay_period = PayPeriod.find_or_create_by_id(pay_period)
    end
    @pay_period = pay_period
  end

  def reset
    pay_period.bonus_payments.pending.destroy_all
  end

  def invoke
    bonuses.each { |bonus| bonus.create_payments!(self) }
  end

  def invoke!
    reset
    invoke
  end

  def leads
    @leads ||= {}
  end

  def status_leads(status)
    leads[status] ||= begin
      Lead
        .send(status, pay_period_id: pay_period.id)
        .preload(:user, user: :product_receipts)
    end
  end

  def bonuses
    @bonuses ||= Bonus
      .pay_period(pay_period)
      .preload(:bonus_amounts)
      .order(:id)
  end

  def users
    @users ||= begin
      users = lead_users
      upline_user_ids = users.map(&:upline).flatten.uniq
      missing_user_ids = upline_user_ids - users.map(&:id).uniq
      users.push(*User.find(missing_user_ids))
      Hash[ users.map { |u| [ u.id, u ] } ]
    end
  end

  def find_user(user_id)
    users[user_id] ||= User.find(user_id)
  end

  def user_upline(user, sponsor = false)
    if sponsor
      sponsor_upline(user)
    else
      user.parent_ids.reverse.map { |user_id| find_user(user_id) }
    end
  end

  def compressed_user_upline(user)
    user_upline(user)
  end

  def sponsor_upline(user)
    upline = []
    while user.sponsor_id
      user = find_user(user.sponsor_id)
      upline << user
    end
    upline
  end

  private

  def lead_users
    [ status_leads(:converted).map(&:user),
      status_leads(:contracted).map(&:user),
      status_leads(:installed).map(&:user) ].flatten.uniq
  end

  class << self
    def run_all
      PayPeriod.all.each do |pp|
        calc = BonusCalculator.new(pp.id)
        calc.reset
        calc.invoke!
      end
    end
  end
end

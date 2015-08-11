class BonusCalculator
  attr_reader :pay_period

  def initialize(pay_period)
    if pay_period.is_a?(String)
      pay_period = PayPeriod.find_or_create_by_id(pay_period)
    end
    @pay_period = pay_period
  end

  def reset
    pay_period.bonus_payments.destroy_all
  end

  def invoke
    bonuses.each do |bonus|
      bonus.create_payments!(self)
    end
  end

  def invoke!
    reset
    invoke
  end

  def converted_leads
    @converted_leads ||= Lead
      .converted(pay_period_id: pay_period.id).preload(:user)
  end

  def contracted_leads
    @contracted_leads ||= Lead
      .contracted(pay_period_id: pay_period.id).preload(:user)
  end

  def installed_leads
    @installed_leads ||= Lead
      .installed(pay_period_id: pay_period.id).preload(:user)
  end

  def bonuses
    @bonuses ||= begin
      Bonus
        .send(pay_period.time_span)
        .where('start_date IS NULL OR start_date <= ?', pay_period.start_date)
        .preload(:bonus_amounts)
    end
  end

  private

  class << self
    def run_all
      PayPeriod.generate_missing
      PayPeriod.all.each do |pp|
        calc = BonusCalculator.new(pp.id)
        calc.reset
        calc.invoke!
      end
    end
  end
end

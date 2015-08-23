class MonthlyPayPeriod < PayPeriod
  def time_span
    :monthly
  end

  def type_display
    'Monthly'
  end

  before_create do
    self.end_date ||= start_date.end_of_month
  end

  def bonuses
    @bonuses ||= Bonus.monthly
  end

  class << self
    def id_from(date)
      date.strftime('%Y-%m')
    end

    def ids_from(date)
      now = DateTime.current
      diff = (now.year * 12 + now.month) - (date.year * 12 + date.month)
      (0...diff).map { |i| id_from(date + i.months) }
    end

    def date_from(id)
      Date.parse("#{id}-01")
    end

    def end_date_from_id(id)
      date_from(id).end_of_month
    end

    def find_or_create_by_id(id)
      find_or_create_by(id: id) do |period|
        period.start_date = date_from(id)
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def first_pay_period_id
      SystemSettings.first_monthly_pay_period
    end
  end
end

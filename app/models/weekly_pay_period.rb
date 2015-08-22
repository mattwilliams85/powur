class WeeklyPayPeriod < PayPeriod
  def time_span
    :weekly
  end

  def type_display
    'Weekly'
  end

  before_create do
    self.end_date ||= start_date.end_of_week + 1.day
  end

  def rank_has_path?(rank, path_id)
    rank.weekly_path?(path_id)
  end

  def active_qualifiers
    @active_qualifiers ||= begin
      super.select { |q| !q.weekly? }.group_by(&:rank_path_id)
    end
  end

  def bonus_available?(bonus)
    bonus.weekly?
  end

  def week_number
    week_of_month
  end

  class << self
    def date_from(id)
      Date.parse(id)
    end

    def id_from(date)
      date.strftime('%GW%V')
    end

    def ids_from(date)
      now = Date.current
      diff = (now.mjd - date.to_date.mjd) / 7
      (0...diff).map { |i| id_from(date + i.weeks) }
    end

    def find_or_create_by_id(id)
      find_or_create_by(id: id) do |period|
        period.start_date = Date.parse(id)
        # period.end_date = period.start_date.end_of_week
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def first_pay_period_id
      SystemSettings.first_weekly_pay_period
    end
  end
end

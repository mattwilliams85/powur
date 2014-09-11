class MonthlyPayPeriod < PayPeriod

  def type_display
    'Monthly'
  end

  def rank_has_path?(rank, path)
    rank.monthly_path?(path)
  end

  def active_qualifications
    @active_qualifications ||= Qualification.active.where.
      not(time_period: Qualification.time_periods[:weekly]).group_by(&:path)
  end

  def bonus_available?(bonus)
    bonus.monthly?
  end

  private

  class << self
    def id_from(date)
      date.strftime('%Y-%m')
    end

    def ids_from(date)
      now = DateTime.current
      diff = (now.year * 12 + now.month) - (date.year * 12 + date.month)
      (0...diff).map { |i| id_from(date + i.months) }
    end

    def find_or_create_by_id(id)
      find_or_create_by(id: id) do |period|
        period.start_date = Date.parse("#{id}-01")
        period.end_date = period.start_date.end_of_month
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end

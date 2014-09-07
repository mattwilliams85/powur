class WeeklyPayPeriod < PayPeriod

  def type_display
    'Weekly'
  end

  def rank_has_path?(rank, path)
    rank.weekly_path?(path)
  end

  class << self
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
        period.end_date = period.start_date.end_of_week
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

end

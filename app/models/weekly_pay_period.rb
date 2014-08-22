class WeeklyPayPeriod < PayPeriod

  def type_display
    'Weekly'
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

    def create_from_id(id)
      start_date = Date.parse(id)

      attrs = { id:         id,
                start_date: start_date,
                end_date:   start_date.end_of_week }
      create!(attrs)
    end
  end

end

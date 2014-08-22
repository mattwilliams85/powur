class MonthlyPayPeriod < PayPeriod

  has_many :rank_achievements

  def type_display
    'Monthly'
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

    def create_from_id(id)
      start_date = Date.parse("#{id}-01")
      attrs = { id:         id,
                start_date: start_date,
                end_date:   start_date.end_of_month }
      create!(attrs)
    end
  end
end

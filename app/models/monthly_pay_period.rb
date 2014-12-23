class MonthlyPayPeriod < PayPeriod
  def type_display
    'Monthly'
  end

  before_create do
    self.end_date ||= start_date.end_of_month
  end

  def rank_has_path?(rank, path_id)
    rank.monthly_path?(path_id)
  end

  def active_qualifiers
    @active_qualifiers ||= begin
      super.select { |q| !q.weekly? }.group_by(&:rank_path_id)
    end
  end

  def bonus_available?(bonus)
    bonus.monthly?
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

    def find_or_create_by_id(id)
      find_or_create_by(id: id) do |period|
        period.start_date = Date.parse("#{id}-01")
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end

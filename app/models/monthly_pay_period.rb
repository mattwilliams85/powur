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

    def start_date_from_id(id)
      Date.parse("#{id}-01")
    end

    def end_date_from_id(id)
      start_date_from_id(id).end_of_month
    end

    def find_or_create_by_id(id)
      find_or_create_by(id: id) do |period|
        period.start_date = start_date_from_id(id)
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def relevant_ids(current: false)
      first_lead = Lead.converted.order(:converted_at).first
      return [] unless first_lead
      result = ids_from(first_lead.converted_at)
      result << current_id if current && !result.include?(current_id)
      result
    end
  end
end

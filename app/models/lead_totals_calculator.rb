class LeadTotalsCalculator
  attr_reader :pay_period, :records, :user_id

  COUNTS_FIELDS = [ :personal, :personal_lifetime, :team, :team_lifetime ]

  def initialize(pay_period, user_id: nil)
    @pay_period =
      if pay_period.is_a?(String)
        MonthlyPayPeriod.find_or_create_by_id(pay_period)
      else
        pay_period
      end
    @user_id = user_id
    init_records
  end

  def calculate
    hydrate_counts
    hydrate_smaller_legs
  end

  def save
    LeadTotals.create!(record_attrs)
  end

  def calculate!
    calculate
    save
  end

  private

  def statuses
    LeadTotals.statuses.keys
  end

  def user_query
    user_id ? User.all_team(user_id) : User
  end

  def init_records
    users = user_query.select(:id, :upline).order(:id)
    @records = users.map do |user|
      attrs = { user: user }
      statuses.each { |s| attrs[s] = {} }
      attrs
    end
  end

  def for_team?(field)
    field.to_s.start_with?('team')
  end

  def query_args_for_field(field)
    if field.to_s.end_with?('_lifetime')
      { to: pay_period.end_date + 1.day }
    else
      { pay_period_id: pay_period.id }
    end
  end

  def lead_status_query(field, status)
    args = query_args_for_field(field)
    Lead.send(status, args)
  end

  def query_counts(field, status)
    lead_query = lead_status_query(field, status)
    count_query = for_team?(field) ? :team_lead_count : :lead_count
    user_query.send(count_query, lead_query)
  end

  def hydrate_counts
    COUNTS_FIELDS.each do |field|
      statuses.each do |status|
        counts = query_counts(field, status).entries
        records.each do |record|
          count = counts.detect { |u| u.id == record[:user].id }
          record[status][field] = count.attributes['lead_count'] || 0
        end
      end
    end
  end

  def smaller_legs_count(status, user_id, personal)
    children = records.select { |r| r[:user].parent_id == user_id }
    return personal if children.empty?

    counts = children.map { |c| c[status][:team] }
    # remove highest leg and add personal
    smaller_legs = counts.inject(&:+) - counts.max
    smaller_legs + personal
  end

  def hydrate_smaller_legs
    records.each do |record|
      statuses.each do |status|
        count = smaller_legs_count(
          status,
          record[:user].id,
          record[status][:personal])
        record[status][:smaller_legs] = count
      end
    end
  end

  def record_attrs
    records.map do |record|
      statuses.map do |status|
        record[status].merge(
          pay_period_id: pay_period.id,
          user_id:       record[:user].id,
          status:        status)
      end
    end.flatten
  end
end

class LeadTotalsCalculator
  attr_reader :pay_period, :status, :records, :user_id

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

  def calculate!
    statuses.each do |status|
      @status = status
      COUNTS_FIELDS.each { |field| hydrate_counts(field) }
      hydrate_smaller_legs
      LeadTotals.create!(record_attrs)
    end
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

  def generate_lead_query(field)
    args = query_args_for_field(field)
    Lead.send(status, args)
  end

  def query_counts(field)
    lead_query = generate_lead_query(field)
    if for_team?(field)
      user_query.team_lead_count(lead_query)
    else
      user_query.lead_count(lead_query)
    end
  end

  def hydrate_counts(field)
    counts = query_counts(field).entries
    records.each do |record|
      count = counts.detect { |u| u.id == record[:user].id }
      record[status][field] = count.attributes['lead_count'] || 0
    end
  end

  def smaller_legs_count(user_id, personal)
    children = records.select { |r| r[:user].parent_id == user_id }
    return personal if children.empty?

    counts = children.map { |c| c[status][:team] }
    # remove highest leg and add personal
    smaller_legs = counts.inject(&:+) - counts.max
    smaller_legs + personal
  end

  def hydrate_smaller_legs
    records.each do |record|
      count = smaller_legs_count(record[:user].id, record[status][:personal])
      record[status][:smaller_legs] = count
    end
  end

  def record_attrs
    records.map do |record|
      record[status].merge(
        pay_period_id: pay_period.id,
        user_id:       record[:user].id,
        status:        status)
    end
  end
end

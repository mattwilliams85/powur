class LeadTotalsCalculator
  attr_reader :pay_period, :status, :records, :counts

  COUNTS_FIELDS = [ :personal, :personal_lifetime, :team, :team_lifetime ]

  def initialize(pay_period, status)
    @pay_period = pay_period
    @status = status
    init_records
    @counts = {}
  end

  def calculate
    COUNTS_FIELDS.each { |field| hydrate_counts(field) }
    hydrate_smaller_legs
  end

  def save
    LeadTotals.create!(record_attrs)
  end

  private

  def init_records
    @records = User.select(:id, :upline).map { |u| { user: u } }
  end

  def record_attrs
    records.map do |attrs|
      attrs.merge(
        pay_period_id: pay_period.id,
        status:        status)
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

  def add_count_field(field)
    records.each do |record|
      user = counts[field].detect { |u| u.id == record[:user].id }
      record[field] = user.attributes['lead_count'] || 0
    end
  end

  def generate_lead_query(field)
    args = query_args_for_field(field)
    status == :converted ? Lead.converted(args) : Lead.contracted(args)
  end

  def query_counts(field)
    lead_query = generate_lead_query(field)
    if for_team?(field)
      User.team_lead_count(lead_query)
    else
      User.lead_count(lead_query)
    end
  end

  def hydrate_counts(field)
    counts[field] = query_counts(field).entries
    add_count_field(field)
  end

  def smaller_legs_count(user_id, personal)
    children = records.select { |r| r[:user].parent_id == user_id }
    return 0 if children.empty?
    counts = children.map { |c| c[:team] }
    # remove highest leg and add personal
    result = counts.inject(&:+) - counts.max
    result + personal
  end

  def hydrate_smaller_legs
    records.each do |record|
      user_id = record[:user].id
      count = smaller_legs_count(user_id, record[:personal])
      record[:smaller_legs] = count
    end
  end
end

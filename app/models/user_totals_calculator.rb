class UserTotalsCalculator
  attr_reader :pay_period_id, :user_totals, :current_status, :lead_counts

  def initialize(pay_period_id = nil)
    @pay_period_id = pay_period_id
    @user_totals = {}
  end

  def calculate
    UserTotals::LEAD_STATUSES.each do |status|
      @current_status = status
      @lead_counts = fetch_lead_counts
      hydrate_personal_counts
      hydrate_team_counts
    end
  end

  def save
    user_totals.values.each(&:save!)
  end

  def calculate!
    calculate
    save
  end

  private

  def fetch_lead_counts
    Lead
      .send(current_status, pay_period_id: pay_period_id)
      .user_count.preload(:user)
  end

  def hydrate_personal_counts
    lead_counts.each do |record|
      totals = user_totals[record.user_id] ||= UserTotals
        .find_or_create_by(id: record.user_id)
      method(personal_prop_set).call(totals, record.lead_count)
    end
  end

  def hydrate_team_counts
    parent_ids = lead_counts.map(&:user).map(&:parent_ids).flatten.uniq
    parent_ids.each do |parent_id|
      totals = user_totals[parent_id] ||= UserTotals
        .find_or_create_by(id: parent_id)
      counts = calculate_team_lead_counts(parent_id)
      method(team_prop_set).call(totals, counts)
    end
  end

  def calculate_team_lead_count(parent_id)
    counts = lead_counts.select { |r| r.user.upline.include?(parent_id) }
    counts.map(&:lead_count).inject(:+)
  end

  def calculate_team_lead_counts(parent_id)
    uplines = lead_counts.select do |record|
      record.user.ancestor?(parent_id)
    end.map(&:user).map(&:upline)
    children = uplines.map do |upline|
      index = upline.index(parent_id) + 1
      upline[index]
    end.uniq
    children.map { |user_id| calculate_team_lead_count(user_id) }
  end

  def personal_prop_set
    @personal_prop_set ||=
        if pay_period_id
          :personal_pay_period_leads_set
        else
          :personal_lifetime_leads_set
        end
  end

  def team_prop_set
    @team_prop_set ||=
        if pay_period_id
          :team_pay_period_leads_set
        else
          :team_lifetime_leads_set
        end
  end

  def personal_pay_period_leads_set(totals, count)
    period = totals.monthly_leads[pay_period_id] ||= {}
    period[current_status] = count
  end

  def team_pay_period_leads_set(totals, counts)
    period = totals.monthly_team_leads[pay_period_id] ||= {}
    period[current_status] = counts
  end

  def personal_lifetime_leads_set(totals, count)
    totals.lifetime_leads[current_status] = count
  end

  def team_lifetime_leads_set(totals, counts)
    totals.team_leads[current_status] = counts
  end
end

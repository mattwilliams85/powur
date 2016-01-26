class UserTotals < ActiveRecord::Base
  belongs_to :user, foreign_key: :id
  LEAD_STATUSES = [ :submitted, :converted, :closed_won,
                    :contracted, :installed ]
  include UserTotalsScopes

  def personal_lead_count(status, month = nil)
    counts = month ? (monthly_leads[month] || {}) : lifetime_leads
    counts[status.to_s] || 0
  end

  def team_lead_counts(status, month = nil)
    counts = month ? (monthly_team_leads[month] || {}) : team_leads
    counts[status.to_s] || []
  end

  def legs_lead_count(status, month = nil)
    team_lead_counts(status, month).inject(:+)
  end

  def team_lead_count(status, month = nil)
    legs_lead_count(status, month) + personal_lead_count(status, month)
  end

  def min_legs_count?(status, leg_count, quantity)
    status = status.to_s
    return false unless team_leads[status]
    team_leads[status].select { |i| i >= quantity }.size >= leg_count
  end

  def progress_for_requirement(req, month)
    month = nil unless req.monthly?
    if req.team?
      if req.leg_count?
        totals = team_lead_counts(req.lead_status, month)
        totals.sort.reverse[0...req.leg_count]
      else
        team_lead_count(req.lead_status, month)
      end
    else
      personal_lead_count(req.lead_status, month)
    end
  end

  class << self
    def calculate(pay_period_id = nil)
      calc = UserTotalsCalculator.new(pay_period_id)
      calc.calculate!
    end

    def calculate_latest
      calculate(MonthlyPayPeriod.current_id)
    end

    def calculate_all
      MonthlyPayPeriod.relevant_ids.each { |id| calculate(id) }
      calculate
    end
  end
end

class LeadTotals < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  belongs_to :pay_period

  enum status: [ :converted, :contracted ]

  scope :exclude_users, lambda { |query|
    joins("LEFT JOIN (#{query.to_sql}) eu
          ON lead_totals.user_id = eu.user_id")
      .where('eu.user_id IS NULL')
  }
  scope :include_users, lambda { |query|
    joins("INNER JOIN (#{query.to_sql}) iu
          ON lead_totals.user_id = iu.user_id")
  }

  def personal_count
    self.personal ||= lead_query.where(user_id: user_id).count
  end

  def personal_lifetime_count
    self.personal_lifetime ||= lifetime_lead_query.where(user_id: user_id).count
  end

  def team_count
    self.team ||= Lead.team_count(user_id: user_id, query: lead_query)
  end

  def team_lifetime_count
    self.team_lifetime ||= begin
      Lead.team_count(user_id: user_id, query: lifetime_lead_query)
    end
  end

  private

  def lead_query
    Lead.send(status, pay_period_id: pay_period_id)
  end

  def lifetime_lead_query
    Lead.send(status, to: pay_period.end_date + 1.day)
  end

  class << self
    def calculate_for_pay_period!(pay_period_id)
      transaction do
        LeadTotals.where(pay_period_id: pay_period_id).delete_all
        LeadTotalsCalculator.new(pay_period_id).calculate!
      end
    end

    def calculate_all!
      MonthlyPayPeriod.relevant_ids(current: true).each do |pp_id|
        calculate_for_pay_period!(pp_id)
      end
    end

    def calculate_latest
      calculate_for_pay_period!(MonthlyPayPeriod.current_id)
    end

    def find_or_initialize(user_id:, pay_period_id:, status:)
      attrs = { user_id: user_id, pay_period_id: pay_period_id }
      result = send(status).where(attrs).first
      return result if result
      calc = LeadTotalsCalculator.new(pay_period_id, user_id: user_id)
      calc.calculate!
      send(status).where(attrs).first
    end

    def add_totals_to_csv_row(row, user_id, lead_totals, status)
      totals = lead_totals.detect do |lt|
        lt.user_id == user_id && lt.status == status.to_s
      end

      if totals
        row.push(totals.personal, totals.personal_lifetime,
                 totals.team, totals.team_lifetime)
        row << totals.smaller_legs
      else
        row.push(0, 0, 0, 0, 0)
      end
    end

    CSV_HEADERS = [
      'User ID', 'First Name', 'Last Name', 'Certified',
      'Personal Proposals (month)',
      'Personal Proposals (lifetime)',
      'Team Proposals (month)',
      'Team Proposals (lifetime)',
      'Team Proposals (month, minus largest leg)',
      'Personal Contracted (month)',
      'Personal Contracted (lifetime)',
      'Team Contracted (month)',
      'Team Contracted (lifetime)',
      'Team Contracted (month, minus largest leg)',
      'Pay As Rank' ]
    def to_csv(pay_period_id)
      users = User.order(:id).entries
      lead_totals = where(pay_period_id: pay_period_id).entries
      highest_ranks = UserUserGroup
        .highest_ranks(pay_period_id: pay_period_id)
      receipts = ProductReceipt
        .joins(:product)
        .where(products: { slug: 'partner' })
        .entries

      filename = "/tmp/rank_achievements_#{pay_period_id}.csv"

      CSV.open(filename, 'w') do |csv|
        csv << CSV_HEADERS
        users.each do |user|
          row = [ user.id, user.first_name, user.last_name ]
          partner = receipts.any? { |r| r.user_id == user.id }
          row << partner
          [ :converted, :contracted ].each do |status|
            add_totals_to_csv_row(row, user.id, lead_totals, status)
          end
          pay_as_rank = user.pay_as_rank(highest_ranks: highest_ranks)
          row << pay_as_rank
          csv << row
        end
      end

      users.size
    end

    def run_all_csvs!(pp_ids = nil)
      pp_ids ||= MonthlyPayPeriod.relevant_ids
      pp_ids.each { |pp_id| to_csv(pp_id) }
    end
  end
end

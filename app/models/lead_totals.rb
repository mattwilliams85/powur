class LeadTotals < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  belongs_to :pay_period

  enum status: [ :converted, :contracted ]

  def requirement_met?(req)
    return false unless quantity_from_req(req) >= req.quantity
    return true if !req.max_leg? || req.max_leg == 0
    smaller_legs >= req.smaller_legs_amount_needed
  end

  private

  def quantity_from_req(requirement)
    send(requirement.lead_totals_quantity_column)
  end

  class << self
    def calculate_for_pay_period!(pay_period_id)
      LeadTotals.where(pay_period_id: pay_period_id).delete_all
      pp = PayPeriod.find_or_create_by_id(pay_period_id)
      [ :converted, :contracted ].each do |status|
        calculator = LeadTotalsCalculator.new(pp, status)
        calculator.calculate
        calculator.save
      end
    end

    def calculate_all!
      MonthlyPayPeriod.relevant_ids.each do |pp_id|
        calculate_for_pay_period!(pp_id)
      end
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

    CSV_HEADERS = %w(
      user_id first_name last_name certified
      personal_converted personal_converted_lifetime
      team_converted team_converted_lifetime
      smaller_legs_converted
      personal_contracted personal_contracted_lifetime
      team_contracted team_contracted_lifetime
      smaller_legs_contracted
      rank_achieved)
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
          rank_achieved = user.pay_as_rank(highest_ranks: highest_ranks)
          row << rank_achieved
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

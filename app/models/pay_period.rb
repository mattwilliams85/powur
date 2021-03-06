class PayPeriod < ActiveRecord::Base # rubocop:disable ClassLength
  has_many :bonus_payments, dependent: :destroy
  belongs_to :distribution

  enum status: [
    :pending, :queued, :calculating,
    :calculated, :distributing, :distributed ]

  scope :calculated, -> { where('calculated_at is not null') }
  scope :next_to_calculate,
        -> { order(id: :asc).where('calculated_at is null').first }
  scope :within_date_range,
        ->(start_date, end_date) { where(end_date: start_date..end_date) }
  scope :time_span,
        ->(span) { where(type: "#{span.to_s.capitalize}PayPeriod") }
  scope :calculable, lambda {
    statuses = [ :pending, :calculated ].map { |s| PayPeriod.statuses[s] }
    PayPeriod.where(status: statuses)
  }
  scope :disbursable, lambda {
    PayPeriod.calculated.where('end_date < ?', Date.current)
  }
  scope :user_has_bonuses, lambda { |user_id|
    join = BonusPayment.where(user_id: user_id).select(:pay_period_id).distinct
    joins("INNER JOIN (#{join.to_sql}) bp ON bp.pay_period_id = pay_periods.id")
  }

  before_create do
    self.id ||= self.class.id_from(start_date)
  end

  def monthly?
    time_span == :monthly
  end

  def weekly?
    !monthly?
  end

  def title
    "#{type_display} (#{start_date} - #{end_date})"
  end

  def date_range_display(format = nil)
    if format
      "#{start_date.strftime(format)} - #{end_date.strftime(format)}"
    else
      "#{start_date} - #{end_date}"
    end
  end

  def started?
    DateTime.current >= start_date
  end

  def finished?
    Date.current > end_date
  end

  def disbursable?
    finished? && calculated? && bonus_payments.count > 0
  end

  def distribute!
    self.distribution ||= create_distribution(batch_id: id.to_s + ':')

    update_attributes(
      status:         PayPeriod.statuses[:distributed],
      distributed_at: DateTime.current)

    distribution.distribute_pay_period!(self)
  end

  def calculable?
    started? && (pending? || calculated?)
  end

  def calculate!
    BonusCalculator.new(self).invoke!
    update_attributes(
      total_bonus:   bonus_payments.sum(:amount),
      status:        PayPeriod.statuses[:calculated],
      calculated_at: DateTime.current)
  end

  def contains_date?(date)
    date >= start_date && date < (end_date + 1.day)
  end

  def bonus_total
    @payment_sum ||= bonus_payments.sum(:amount)
  end

  def bonus_totals
    bonuses = BonusPayment.bonus_totals_by_type(self)
    bonuses.map do |i|
      { id:     i.bonus_id,
        amount: i.amount,
        type:   Bonus.find(i.bonus_id).name }
    end
  end

  private

  class << self
    def current
      find_or_create_by_date(Date.current)
    end

    def current_id
      id_from(Date.current)
    end

    def find_or_create_by_date(date)
      find_or_create_by_id(id_from(date.to_date))
    end

    def generate_missing
      first_lead = Lead.converted.order(:converted_at).first
      return unless first_lead

      [ MonthlyPayPeriod, WeeklyPayPeriod ].each do |klass|
        ids = klass.relevant_ids
        next if ids.empty?

        ids.each { |id| klass.find_or_create_by_id(id) }
      end
    end

    def find_or_create_by_id(id)
      klass = id.include?('W') ? WeeklyPayPeriod : MonthlyPayPeriod
      klass.find_or_create_by_id(id)
    end

    def last_id
      most_recent = calculated.order(start_date: :desc).first
      most_recent && most_recent.id
    end

    def relevant_ids(current: false)
      first_id = first_pay_period_id
      first_date = first_id ? date_from(first_id) : Date.current
      result = ids_from(first_date)
      result << current_id if current && !result.include?(current_id)
      result
    end

    def run_csvs
      pay_period_ids = BonusPayment.select(:pay_period_id)
        .group(:pay_period_id).map(&:pay_period_id)

      pay_period_ids.each do |pp_id|
        period = PayPeriod.find(pp_id)
        period.to_csv
      end
    end
  end

  CSV_HEADERS = [
    'User ID', 'First Name', 'Last Name', 'Bonus', 'Lead ID',
    'Lead Owner ID', 'Lead Owner Name', 'Lead Customer',
    'Lead Payment Status', 'Lead Converted', 'Lead Contracted',
    'Lead Installed', 'Bonus Data', 'Amount' ]
  def to_csv
    payments = bonus_payments
      .joins(:bonus)
      .where('bonuses.schedule <> 3')
      .preload(:bonus, :user, :bonus_payment_leads, :leads,
               leads: [ :user, :customer ])
      .order(:user_id)

    filename = "/tmp/pay_period_bonuses_#{id}.csv"

    CSV.open(filename, 'w') do |csv|
      csv << CSV_HEADERS
      payments.each do |payment|
        user = payment.user
        bpl = payment.bonus_payment_leads.first
        lead = bpl.lead
        csv << [
          user.id, user.first_name, user.last_name, payment.bonus.name,
          bpl.lead_id, lead.user_id,
          lead.user.full_name, lead.full_name,
          bpl.status,
          lead.converted_at && lead.converted_at.strftime('%F'),
          lead.contracted_at && lead.contracted_at.strftime('%F'),
          lead.installed_at && lead.installed_at.strftime('%F'),
          payment.bonus_data, payment.amount.to_f ]
      end
    end

    payments.size
  end
end

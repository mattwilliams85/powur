class PayPeriod < ActiveRecord::Base # rubocop:disable ClassLength
  has_many :lead_totals, class_name: 'LeadTotals', dependent: :destroy
  has_many :bonus_payments, dependent: :destroy

  scope :calculated, -> { where('calculated_at is not null') }
  scope :next_to_calculate,
        -> { order(id: :asc).where('calculated_at is null').first }
  scope :disbursed, -> { where('disbursed_at is not null') }
  scope :within_date_range,
        ->(start_date, end_date) { where(end_date: start_date..end_date) }
  scope :time_span,
        ->(span) { where(type: "#{span.to_s.capitalize}PayPeriod") }

  before_create do
    self.id ||= self.class.id_from(start_date)
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

  def finished?
    Date.current > end_date
  end

  def disbursed?
    !disbursed_at.nil?
  end

  def disbursable?
    finished? && calculated? && !disbursed?
  end

  def disburse!
    # payments_per_user = BonusPayment.user_bonus_totals(self)
  end

  def calculated?
    !calculated_at.nil?
  end

  def calculating?
    !calculate_started.nil? && !calculated?
  end

  def calculable?
    !disbursed? && DateTime.current > start_date && !calculating?
  end

  def queue_calculate
    touch(:calculate_queued)
    update_attribute(:calculate_started, nil)
    delay.calculate!
  end

  def status
    case self
    when disbursed?
      'disbursed'
    when calculated?
      'calculated'
    when calculating?
      'calculating'
    when calculate_queued
      'queued'
    end
  end

  def calculate!
  end

  def contains_date?(date)
    date >= start_date && date < (end_date + 1.day)
  end

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

      [ MonthlyPayPeriod, WeeklyPayPeriod ].each do |period_klass|
        ids = period_klass.ids_from(first_lead.converted_at)
        next if ids.empty?
        existing = period_klass.where(id: ids).pluck(:id)
        ids -= existing
        ids.each { |id| period_klass.find_or_create_by_id(id) }
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
  end
end

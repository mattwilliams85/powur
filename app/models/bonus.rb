class Bonus < ActiveRecord::Base # rubocop:disable ClassLength
  enum schedule: { weekly: 1, monthly: 2, one_time: 3 }

  has_many :bonus_amounts,
           class_name:  'BonusAmount',
           foreign_key: :bonus_id,
           dependent:   :destroy
  has_many :bonus_payments
  belongs_to :distribution
  belongs_to :pay_period

  scope :started, lambda { |start_date|
    where('start_date IS NULL OR start_date <= ?', start_date)
  }
  scope :pay_period, lambda { |pay_period|
    condition = 'schedule = ? OR (schedule = 3 AND pay_period_id = ?)'
    schedule = Bonus.schedules[pay_period.time_span]
    where(condition, schedule, pay_period).started(pay_period.start_date)
  }

  validates_presence_of :name

  class << self
    def symbol_to_type(type_symbol)
      "#{type_symbol.to_s.split('_').map(&:capitalize).join}#{name}"
        .constantize
    end

    def meta_data_fields
      (typed_store_attributes || {})[:meta_data] || {}
    end
  end
end

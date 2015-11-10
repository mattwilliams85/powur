class Bonus < ActiveRecord::Base
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
  scope :not_ended, lambda { |end_date|
    where('end_date IS NULL OR end_date > ?', end_date)
  }
  scope :pay_period, lambda { |pay_period|
    condition = 'schedule = ? OR (schedule = 3 AND pay_period_id = ?)'
    schedule = Bonus.schedules[pay_period.time_span]
    where(condition, schedule, pay_period.id)
      .started(pay_period.start_date)
      .not_ended(pay_period.start_date)
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

    def seed_attrs
      path = Rails.root.join('db', 'seed', 'bonuses.yml')
      YAML.load_file(path)['bonuses']
    end

    def create_or_update_bonus_from_attrs(bonus_attrs)
      bonus_amounts = bonus_attrs.delete('bonus_amounts')
      id = bonus_attrs['id']
      if id && (bonus = Bonus.find_by(id: id))
        bonus_attrs.delete('id')
        bonus.update_attributes(bonus_attrs)
        bonus.bonus_amounts.delete_all
      else
        bonus = Bonus.create!(bonus_attrs)
      end

      return unless bonus_amounts
      bonus_amounts.each do |attrs|
        bonus.bonus_amounts.create!(attrs)
      end
    end

    def update_attrs!
      seed_attrs.each do |attrs|
        next if block_given? && !yield(attrs)
        create_or_update_bonus_from_attrs(attrs)
      end
    end
  end
end

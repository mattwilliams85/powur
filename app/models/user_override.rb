class UserOverride < ActiveRecord::Base
  belongs_to :user

  enum kind: { active: 1, pay_as_rank: 2, unqualified: 3 }

  store_accessor :data, :rank

  scope :pay_period, lambda { |pay_period_id|
    end_date = MonthlyPayPeriod.end_date_from_id(pay_period_id)
    where('start_date IS NULL OR start_date <= ?', end_date)
      .where('end_date IS NULL OR end_date > ?', end_date)
  }

  def started?(date)
    start_date.nil? || start_date <= date
  end

  def ended?(date)
    end_date? && end_date < date
  end

  def active?(date)
    started?(date) && !ended?(date)
  end

  def pay_period?(pay_period_id)
    date =
      if pay_period_id =~ /W/
        Date.parse(pay_period_id)
      else
        Date.strptime(pay_period_id, '%Y-%m')
      end

    active?(date)
  end
end

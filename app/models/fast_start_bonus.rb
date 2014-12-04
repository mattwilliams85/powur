class FastStartBonus < Bonus
  TIME_PERIODS = %w(days months years)

  store_accessor :meta_data, :time_period, :time_amount

  validates :time_period, inclusion: { in: TIME_PERIODS }, allow_nil: true
  validates :time_amount,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil:    true

  def time_amount_int
    time_amount.presence && time_amount.to_i
  end
end

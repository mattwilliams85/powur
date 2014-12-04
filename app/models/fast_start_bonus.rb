class FastStartBonus < Bonus
  TIME_PERIODS = %w(days months years)

  store_accessor :meta_data, :time_period, :time_amount

  validates :time_period, inclusion: { in: TIME_PERIODS }
  validates :time_amount, numericality: { only_integer: true, greater_than: 0 }

  def time_amount
    super.to_i
  end
end

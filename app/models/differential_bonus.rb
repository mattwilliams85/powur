class DifferentialBonus < Bonus

  belongs_to :max_user_rank, class_name: 'Rank'
  belongs_to :min_upline_rank, class_name: 'Rank'

  def create_payments!(order, pay_period)
  end
end

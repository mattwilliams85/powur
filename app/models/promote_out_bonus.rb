class PromoteOutBonus < Bonus

  belongs_to :min_upline_rank, class_name: 'Rank'
  belongs_to :achieved_rank, class_name: 'Rank'
end

class DifferentialBonus < Bonus
  include BonusEnums

  belongs_to :max_user_rank, class_name: 'Rank'
  belongs_to :min_upline_rank, class_name: 'Rank'
end

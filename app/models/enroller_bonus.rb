class EnrollerBonus < Bonus
  include SalesBonus

  store_accessor :data, :min_upline_rank, :max_downline_rank 
end
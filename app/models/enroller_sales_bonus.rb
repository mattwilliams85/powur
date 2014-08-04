class EnrollerSalesBonus < Bonus

  belongs_to :max_user_rank, class_name: 'Rank'
  belongs_to :min_upline_rank, class_name: 'Rank'

  # def rank_range
  #   @rank_range ||= begin
  #     if (range = Rank.rank_range)
        
  #     else
  #       nil
  #     end
  #   end
  # end
end

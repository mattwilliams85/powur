module BonusJSON
  def amount_field(bonus)
    field(:amounts, :dollar_percentage,
          array:     true,
          first:     bonus.rank_range.first,
          last:      bonus.rank_range.last,
          value:     bonus.normalized_amounts,
          total:     bonus.available_amount,
          remaining: bonus.remaining_amount,
          max:       bonus.remaining_percentage)
  end

  SirenJson::Action.include(self)
end

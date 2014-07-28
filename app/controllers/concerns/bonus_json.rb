module BonusJSON

  def amount_field(bonus)
    self.field(:amounts, :dollar_percentage, array: true,
      first: bonus.rank_range.first, last: bonus.rank_range.last,
      total: bonus.available_amount, remaining: bonus.remaining_amount,
      max: bonus.remaining_percentage)
  end

  SirenDSL::Action.include(self)
end
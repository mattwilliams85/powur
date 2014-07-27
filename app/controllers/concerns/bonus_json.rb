module BonusJSON
  extend ActiveSupport::Concern

  included do
    helper_method :amount_field
  end

  def amount_field(action, bonus)
    action.field(:amounts, :dollar_percentage, array: true,
      first: bonus.rank_range.first, last: bonus.rank_range.last,
      total: bonus.available_amount, remaining: bonus.remaining_amount,
      max: bonus.remaining_percentage)
  end

end
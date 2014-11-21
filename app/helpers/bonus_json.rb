# class BonusJson < JsonDecorator
#   def list_init(partial_path = 'item')
#     klass :bonuses, :list

#     list_entities(partial_path)
#   end

#   module BonusActions
#     def amount_field(bonus)
#       field(:amounts, :dollar_percentage,
#             array:     true,
#             first:     bonus.rank_range.first,
#             last:      bonus.rank_range.last,
#             value:     bonus.normalized_amounts,
#             total:     bonus.available_amount,
#             remaining: bonus.remaining_amount,
#             max:       bonus.remaining_percentage)
#     end
#   end

#   SirenJson::Action.include(self)
# end

module BonusJson
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


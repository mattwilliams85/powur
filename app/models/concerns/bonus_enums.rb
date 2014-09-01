module BonusEnums
  extend ActiveSupport::Concern

  included do
    # enum schedule:     { weekly: 1, monthly: 2 }
    # enum use_rank_at:  { sale: 1, pay_period_end: 2 }
  end

end

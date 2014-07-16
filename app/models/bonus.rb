class Bonus < ActiveRecord::Base

  SCHEDULES = { weekly: 'Weekly', pay_period: 'Pay Period' }
  PAYS      = { distributor: 'Distributor', upline: 'Upline' }

  enum schedule:  { weekly: 1, pay_period: 2 }
  enum pays:      { distributor: 1, upline: 2 }

  belongs_to :product
  belongs_to :min_distributor_rank, foreign_key: :min_distributor_rank, class_name: 'Rank'
  belongs_to :max_upline_rank, foreign_key: :max_upline_rank, class_name: 'Rank'

  validates_presence_of :schedule, :pays, :product_id

end
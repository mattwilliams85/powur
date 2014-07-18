class Bonus < ActiveRecord::Base

  SCHEDULES = { 
    weekly:   'Weekly', 
    monthly:  'Monthly' }
  PAYS      = { 
    distributor:  'Distributor', 
    upline:       'Upline' }

  enum schedule:  { weekly: 1, monthly: 2 }
  enum pays:      { distributor: 1, upline: 2 }

  belongs_to :achieved_rank, class_name: 'Rank'
  belongs_to :min_user_rank, class_name: 'Rank'
  belongs_to :max_upline_rank, class_name: 'Rank'

  has_many :requirements, class_name: 'BonusSalesRequirement'
  has_many :bonus_levels

  validates_presence_of :name

end
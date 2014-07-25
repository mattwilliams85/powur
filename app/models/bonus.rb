class Bonus < ActiveRecord::Base

  TYPES =  { 
    direct_sales:       'Sales - Distributor',
    enroller_sales:     'Sales - Enroller',
    unilevel_sales:     'Sales - Upline Leveled',
    promote_out:        'Promote-Out',
    differential:       'Differential' }
  SCHEDULES = { 
    weekly:   'Weekly',
    monthly:  'Monthly' }

  enum schedule:  { weekly: 1, monthly: 2 }

  belongs_to :achieved_rank, class_name: 'Rank'

  has_many :requirements, class_name: 'BonusSalesRequirement', dependent: :destroy
  has_many :bonus_levels, dependent: :destroy

  validates_presence_of :type, :name

  def type_string
    self.class.name.underscore.gsub(/_bonus/, '')
  end

  def type_display
    TYPES[type_string.to_sym]
  end

  class << self
    def symbol_to_type(type_symbol)
      "#{type_symbol.to_s.split('_').map(&:capitalize).join}#{self.name}".constantize
    end
  end

end

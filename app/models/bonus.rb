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

  has_many :requirements, class_name: 'BonusSalesRequirement', dependent: :destroy, foreign_key: :bonus_id
  has_many :bonus_levels, dependent: :destroy, class_name: 'BonusLevel'

  validates_presence_of :type, :name

  def type_string
    self.class.name.underscore.gsub(/_bonus/, '')
  end

  def type_display
    TYPES[type_string.to_sym]
  end

  def default_bonus_level
    self.bonus_levels.where(level: 0).first
  end

  def multiple_product_types?
    self.requirements.map(&:product_id).uniq.size > 1
  end

  def bonus_amounts
    @bonus_amounts ||= begin
      rank_range = Rank.rank_range
      if rank_range
        bonus_level = self.bonus_levels.find_by_level(0)
        amounts = bonus_level ? bonus_level.amounts.map(&:to_f) : []
        amounts.fill(0.0, amounts.size...rank_range.last)
        amounts
      else
        []
      end
    end
  end

  def max_bonus_amount
    bonus_amounts ? bonus_amounts.max : 0.0
  end

  def source_requirement
    @source_requirement ||= self.requirements.find_by_source(true)
  end

  def source_requirement?
    !!source_requirement
  end

  def source_product
    source_requirement.product
  end

  def available_bonus_amount
    source_product.bonus_volume
  end

  def available_bonus_percentage
    source_product.total_bonus_allocation(self.id)
  end

  class << self
    def symbol_to_type(type_symbol)
      "#{type_symbol.to_s.split('_').map(&:capitalize).join}#{self.name}".constantize
    end
  end

end

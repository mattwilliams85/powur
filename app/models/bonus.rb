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

  def rank_range
    @rank_range ||= Rank.rank_range
  end

  def default_level
    @default_level ||= self.bonus_levels.find_by_level(0) || BonusLevel.new(level: 0, bonus: self)
  end

  def normalized_amounts
    default_level.normalized_amounts
  end

  def max_amount
    default_level.max
  end

  def source_requirement
    @source_requirement ||= self.requirements.find_by_source(true)
  end

  def has_breakage_amount?
    self.flat_amount && self.flat_amount > 0
  end

  def has_source?
    source_requirement || has_breakage_amount?
  end

  def can_add_amounts?
    rank_range && has_source?
  end

  def source_product
    source_requirement.product
  end

  def percentage_used
    @percentage_used ||= source_product.total_bonus_allocation(self.id)
  end

  def remaining_percentage
    1.0 - percentage_used
  end

  def available_amount
    source_product.bonus_volume
  end

  def remaining_amount
    available_amount * remaining_percentage
  end

  class << self
    def symbol_to_type(type_symbol)
      "#{type_symbol.to_s.split('_').map(&:capitalize).join}#{self.name}".constantize
    end
  end

end

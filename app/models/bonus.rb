class Bonus < ActiveRecord::Base
  TYPES =  {
    direct_sales:   'Direct Sales',
    enroller_sales: 'Enroller',
    unilevel_sales: 'Unilevel',
    promote_out:    'Promote-Out',
    differential:   'Differential' }
  SCHEDULES = {
    weekly:  'Weekly',
    monthly: 'Monthly' }

  enum schedule:     { weekly: 1, monthly: 2 }
  enum use_rank_at:  { sale: 1, pay_period_end: 2 }

  belongs_to :bonus_plan
  belongs_to :achieved_rank, class_name: 'Rank'

  has_many :requirements, class_name: 'BonusSalesRequirement',
    foreign_key: :bonus_id, dependent: :destroy
  has_many :bonus_levels, class_name: 'BonusLevel',
    foreign_key: :bonus_id, dependent: :destroy
  has_many :bonus_payments

  scope :weekly, ->() { where(schedule: :weekly) }
  scope :monthly, ->() { where(schedule: :monthly) }

  validates_presence_of :type, :name

  def type_string
    self.class.name.underscore.gsub(/_bonus/, '')
  end

  def type_display
    TYPES[type_string.to_sym]
  end

  def default_bonus_level
    bonus_levels.where(level: 0).first
  end

  def multiple_product_types?
    requirements.map(&:product_id).uniq.size > 1
  end

  def rank_range
    @rank_range ||= Rank.rank_range
  end

  def default_level
    default_bonus_level || BonusLevel.new(level: 0, bonus: self)
  end

  def normalized_amounts
    default_level.normalized_amounts
  end

  def max_amount
    default_level.max
  end

  def source_requirement
    @source_requirement ||= requirements.find_by_source(true)
  end

  def breakage_amount?
    flat_amount && flat_amount > 0
  end

  def source?
    source_requirement || breakage_amount?
  end

  def can_add_amounts?
    rank_range && source?
  end

  def source_product
    source_requirement.product
  end

  def percentage_used
    @percentage_used ||= source_product.total_bonus_allocation(id)
  end

  def remaining_percentage
    1.0 - percentage_used
  end

  def available_amount
    source_product.commission_amount
  end

  def remaining_amount
    available_amount * remaining_percentage
  end

  def allows_many_requirements?
    false
  end

  def can_add_requirement?
    allows_many_requirements? || requirements.empty?
  end

  def enabled?
    !bonus_levels.empty?
  end

  def rank_amount(rank_id)
    source_product.commission_amount * normalized_amounts[rank_id - 1]
  end

  def create_payments!(*)
  end

  class << self
    def symbol_to_type(type_symbol)
      "#{type_symbol.to_s.split('_').map(&:capitalize).join}#{name}"
        .constantize
    end
  end
end

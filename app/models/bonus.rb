class Bonus < ActiveRecord::Base
  TYPES =  {
    direct_sales: 'Direct Sales',
    enroller:     'Enroller',
    unilevel:     'Unilevel',
    fast_start:   'Fast Start' }
  # differential:   'Differential',
  # promote_out:    'Promote-Out' }
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

  def highest_bonus_level
    bonus_levels.empty? ? 0 : bonus_levels.map(&:level).max
  end

  def next_bonus_level
    0
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

  def max_amount
    default_level.max
  end

  def source_requirement
    @source_requirement ||= requirements.find_by_source(true)
  end

  def sales_requirement?
    !source_requirement.nil?
  end

  def source_product
    source_requirement.product
  end

  def breakage_amount?
    flat_amount && flat_amount > 0
  end

  def source?
    source_requirement || breakage_amount?
  end

  def all_paths_level?
    level = bonus_levels.entries.first
    !level.nil? && level.all_paths?
  end

  def can_add_amounts?(path_count = nil)
    return false if !source? || all_paths_level?

    path_count ||= RankPath.count
    level_count = bonus_levels.entries.size
    (path_count.zero? && level_count.zero?) || path_count > level_count
  end

  def percentages_used(max_rank)
    amounts = if max_level_amounts.size == 1
                max_level_amounts.first
              else
                max_level_amounts.transpose.map { |a| a.inject(:+) }
    end

    amounts.fill(BigDecimal('0'), amounts.size...max_rank)[0...max_rank]
  end

  def remaining_percentages(max_rank)
    other_product_percentages(max_rank).map { |percent| 1.0 - percent }
  end

  def remaining_percentages_for_level(_level_id, max_rank)
    remaining_percentages(max_rank)
  end

  def available_amount
    amount = if sales_requirement?
      source_product.commission_amount * source_requirement.quantity
    else
      0
    end
    amount += flat_amount if breakage_amount?
    amount
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

  def payment_amount(rank_id, path_id, level = 0)
    level = bonus_levels.select { |bl| bl.level == level }.find do |bl|
      bl.rank_path_id.nil? || bl.rank_path_id == path_id
    end
    percent = level.normalize_amounts(rank_id).last
    available_amount * percent
  end

  def create_payments!(*)
  end

  protected

  def other_product_bonuses
    @other_product_bonuses ||= begin
      join_where = { source: true, product_id: source_product.id }
      where = { bonus_sales_requirements: join_where }
      Bonus.where(where).where('id <> ?', id).joins(:requirements)
    end
  end

  def other_product_percentages(max_rank)
    if other_product_bonuses.empty?
      return Array.new(max_rank, BigDecimal('0'))
    end

    percents = other_product_bonuses.map { |b| b.percentages_used(max_rank) }
    percents.map! do |op|
      op.fill(BigDecimal('0'), (op.size...max_rank))[0...max_rank]
    end
    percents.transpose.map { |i| i.reduce(:+) }
  end

  def calculate_max_amounts(levels, max_size = nil)
    max_size ||= levels.map { |l| l.amounts.size }.max
    amounts = levels.map { |l| l.filled_amounts(max_size) }
    amounts.size == 1 ? amounts.first : amounts.transpose.map(&:max)
  end

  def max_level_amounts
    @max_level_amounts ||= begin
      max_size = bonus_levels.map { |level| level.amounts.size }.max
      grouped_amounts = bonus_levels.sort_by(&:level).group_by(&:level)
      grouped_amounts.each do |number, levels|
        grouped_amounts[number] = calculate_max_amounts(levels, max_size)
      end
      grouped_amounts.values
    end
  end

  class << self
    def symbol_to_type(type_symbol)
      "#{type_symbol.to_s.split('_').map(&:capitalize).join}#{name}"
        .constantize
    end
  end
end

class Bonus < ActiveRecord::Base # rubocop:disable ClassLength
  TYPES = {
    'SellerBonus'       => 'Seller',
    'CABonus'           => 'Customer Acquistion',
    'GenerationalBonus' => 'Generational',
    'MatchingBonus'     => 'Matching' }
  SCHEDULES = {
    weekly:  'Weekly',
    monthly: 'Monthly' }

  enum schedule: { weekly: 1, monthly: 2 }

  belongs_to :bonus_plan
  belongs_to :product

  has_many :bonus_amounts, class_name: 'BonusAmount',
    foreign_key: :bonus_id, dependent: :destroy
  has_many :bonus_payments

  scope :weekly, ->() { where(schedule: :weekly) }
  scope :monthly, ->() { where(schedule: :monthly) }

  validates_presence_of :name

  def type_display
    TYPES[self.class.name]
  end

  def highest_bonus_level
    bonus_amounts.empty? ? 0 : bonus_amounts.map(&:level).max
  end

  def next_bonus_level
    0
  end

  def rank_range
    @rank_range ||= Rank.rank_range
  end

  def default_level
    BonusAmount.new(level: 0, bonus: self)
  end

  def max_amount
    default_level.max
  end

  def all_paths_level?
    level = bonus_amounts.entries.first
    !level.nil? && level.all_paths?
  end

  def can_add_amounts?(path_count = nil)
    return false if !product_id || all_paths_level?

    path_count ||= RankPath.count
    level_count = bonus_amounts.entries.size
    (path_count.zero? && level_count.zero?) || path_count > level_count
  end

  def enabled?
    !bonus_amounts.empty?
  end

  def amount_used
    bonus_amounts.empty? ? 0.0 : bonus_amounts.first.max
  end

  def remaining_amount
    return nil unless product
    product.commission_remaining(self)
  end

  def payment_amount(rank_id, path_id, level = 0)
    level = bonus_amounts.select { |ba| ba.level == level }.find do |ba|
      ba.rank_path_id.nil? || ba.rank_path_id == path_id
    end
    percent = level.normalize_amounts(rank_id).last
    available_amount * percent
  end

  def create_payments!(*)
  end

  protected

  class << self
    def symbol_to_type(type_symbol)
      "#{type_symbol.to_s.split('_').map(&:capitalize).join}#{name}"
        .constantize
    end

    def meta_data_fields
      (typed_store_attributes || {})[:meta_data] || {}
    end
  end
end

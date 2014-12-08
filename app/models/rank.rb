class Rank < ActiveRecord::Base
  has_many :qualifications, dependent: :destroy
  has_many :achieved_rank_bonuses, class_name: 'Bonus',
    foreign_key: :achieved_rank_id, dependent: :nullify
  has_many :max_user_rank_bonuses, class_name: 'Bonus',
    foreign_key: :max_user_rank_id, dependent: :nullify
  has_many :min_upline_rank_bonuses, class_name: 'Bonus',
    foreign_key: :min_upline_rank_id, dependent: :nullify

  default_scope -> { order(:id) }
  scope :with_qualifications, lambda {
    includes(:qualifications).references(:qualifications)
  }

  validates_presence_of :title

  before_create do
    self.id ||= Rank.count + 1
  end

  def first?
    id == 1
  end

  # TODO: ineffecient, deprecate
  def last?
    @last_rank ||= Rank.count == id
  end

  def lifetime_path?(path_id)
    list = qualifiers(path_id)
    !list.empty? && list.all?(&:lifetime?)
  end

  def monthly_path?(path_id)
    list = qualifiers(path_id)
    !list.empty? && list.any?(&:monthly?)
  end

  def weekly_path?(path_id)
    list = qualifiers(path_id)
    !list.empty? && list.any?(&:weekly?)
  end

  def grouped_qualifiers
    @grouped_qualifiers ||= qualifications.group_by(&:rank_path_id)
  end

  def qualifiers(path_id)
    @qualifiers ||= {}
    @qualifiers[path_id] ||= (grouped_qualifiers[path_id] || []) +
                             (grouped_qualifiers[nil] || [])
  end

  def qualified_path?(path_id, order_totals)
    !qualifiers(path_id).empty? && qualifiers(path_id).all? do |qualifier|
      if order_totals.product_id == qualifier.product_id
        totals = order_totals
      else
        totals = order_totals.pay_period.find_order_total!(
          order_totals.user_id, qualifier.product_id)
      end
      qualifier.met?(totals)
    end
  end

  private

  def _time_period_path?(period, path_id)
    list = qualifiers(path_id)
    !list.nil? && list.all?(&period)
  end

  class << self
    def rank_range
      return nil unless Rank.count > 0
      (Rank.order(:id).first.id..Rank.order(:id).last.id)
    end

    def find_or_create_by_id(id)
      find_or_create_by(id: id) do |rank|
        rank.title = "Rank #{id}"
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end

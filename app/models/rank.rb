class Rank < ActiveRecord::Base

  has_many :qualifications, dependent: :destroy
  has_many :achieved_rank_bonuses, class_name: 'Bonus',
    foreign_key: :achieved_rank_id, dependent: :nullify
  has_many :max_user_rank_bonuses, class_name: 'Bonus',
    foreign_key: :max_user_rank_id, dependent: :nullify
  has_many :min_upline_rank_bonuses, class_name: 'Bonus',
    foreign_key: :min_upline_rank_id, dependent: :nullify

  default_scope ->(){ order(:id) }
  scope :with_qualifications, ->(){
    includes(:qualifications).references(:qualifications) }

  validates_presence_of :title

  before_create do
    self.id ||= Rank.count + 1
  end

  def last_rank?
    @last_rank ||= Rank.count == self.id
  end

  def lifetime_path?(path)
    !!((list = grouped_qualifications[path]) && list.all?(&:lifetime?))
  end

  def monthly_path?(path)
    !!((list = grouped_qualifications[path]) && list.any?(&:monthly?))
  end

  def weekly_path?(path)
    !!((list = grouped_qualifications[path]) && list.any?(&:weekly?))
  end

  def grouped_qualifications
    @grouped_qualifications ||= self.qualifications.group_by(&:path)
  end

  def qualification_paths
    grouped_qualifications.keys
  end

  def qualified_path?(path, order_totals)
    grouped_qualifications[path].all? do |qualification|
      if order_totals.product_id == qualification.product_id
        totals = order_totals
      else
        totals = order_totals.pay_period.
          find_or_create_order_total(order_totals.user_id, qualification.product_id)
      end
      qualification.met?(totals)
    end
  end

  def display
    "#{self.title} (#{self.id})"
  end

  private

  def _time_period_path?(period, path)
    !!((list = grouped_qualifications[path]) && list.all?(&period))
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

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

  def one_time_qualifiations?
    self.qualifications.all? { |q| q.lifetime? }
  end

  def grouped_qualifications
    @grouped_qualifications ||= self.qualifications.group_by(&:path)
  end

  def qualification_paths
    grouped_qualifications.keys
  end

  class << self
    def rank_range
      return nil unless Rank.count > 0 
      (Rank.order(:id).first.id..Rank.order(:id).last.id)
    end
  end
end

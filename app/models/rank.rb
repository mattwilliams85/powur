class Rank < ActiveRecord::Base

  has_many :qualifications, dependent: :destroy
  has_many :achieved_rank_bonuses, class_name: 'Bonus',
    foreign_key: :achieved_rank_id, dependent: :nullify
  has_many :max_user_rank_bonuses, class_name: 'Bonus',
    foreign_key: :max_user_rank_id, dependent: :nullify
  has_many :min_upline_rank_bonuses, class_name: 'Bonus',
    foreign_key: :min_upline_rank_id, dependent: :nullify

  validates_presence_of :title

  before_create do
    self.id ||= Rank.count + 1
  end

  def last_rank?
    @last_rank ||= Rank.count == self.id
  end

  class << self
    def rank_range
      return nil unless Rank.count > 0 
      (Rank.order(:id).first.id..Rank.order(:id).last.id)
    end
  end
end

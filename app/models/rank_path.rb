class RankPath < ActiveRecord::Base
  has_many :qualifications, dependent: :destroy
  has_many :bonus_amounts, dependent: :destroy
  has_many :users, dependent: :nullify

  validates_presence_of :name

  default_scope -> { order(:precedence) }

  before_validation do
    self.precedence ||= RankPath.last.precedence + 1
  end

  after_create do
    User.where('rank_path_id is null').update_all(rank_path_id: id) if default?
  end

  def default?
    precedence == 1
  end
end

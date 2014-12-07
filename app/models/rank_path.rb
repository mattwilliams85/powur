class RankPath < ActiveRecord::Base
  has_many :qualifications, dependent: :destroy
  has_many :bonus_levels, dependent: :destroy
  has_many :users, dependent: :nullify

  validates_presence_of :name

  after_create do
    User.where('rank_path_id is null').update_all(rank_path_id: id) if default?
  end
end

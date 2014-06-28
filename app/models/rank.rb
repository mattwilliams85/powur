class Rank < ActiveRecord::Base

  has_many :qualifications

  validates_presence_of :title

  before_create do
    self.id ||= Rank.count + 1
  end

  def last_rank?
    @last_rank ||= Rank.count == self.id
  end
end
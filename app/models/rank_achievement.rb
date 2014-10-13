class RankAchievement < ActiveRecord::Base
  belongs_to :rank
  belongs_to :pay_period
  belongs_to :user

  scope :lifetime, -> { where('pay_period_id is null') }
  scope :pay_period, ->(id) { where(pay_period: id) }

  def lifetime?
    pay_period_id.nil?
  end
end

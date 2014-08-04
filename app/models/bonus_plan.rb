class BonusPlan < ActiveRecord::Base

  has_many :bonuses

  ACTIVE_AT_SQL = '(start_year < :start_year) OR (start_year = :start_year AND start_month <= :start_month)'
  scope :active_before, ->(year, month){ 
    where('start_year is not null').
      where('start_month is not null').
      where(ACTIVE_AT_SQL, start_year: year, start_month: month).
      order(start_year: :desc, start_month: :desc) }

  def active?
    if @active.nil?
      current = BonusPlan.current
      @active = !current.nil? && current.id == self.id
    end
    @active
  end

  def has_start?
    !!(self.start_year && self.start_month)
  end

  def active_before_now?
    return false unless has_start?
    year, month = DateTime.now.year, DateTime.now.month
    (self.start_year == year && self.start_month <= month) || 
      self.start_year < year
  end

  class << self
    def current
      year, month = DateTime.now.year, DateTime.now.month
      active_before(year, month).first
    end
  end
end
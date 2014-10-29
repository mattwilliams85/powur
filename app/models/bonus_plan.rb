class BonusPlan < ActiveRecord::Base
  has_many :bonuses, dependent: :destroy

  ACTIVE_AT_SQL = '
    (start_year < :start_year) OR
    (start_year = :start_year AND start_month <= :start_month)'
  scope :active_before, lambda { |year, month|
    where('start_year is not null')
      .where('start_month is not null')
      .where(ACTIVE_AT_SQL, start_year: year, start_month: month)
      .order(start_year: :desc, start_month: :desc)
  }

  def active?
    if @active.nil?
      current = BonusPlan.current
      @active = !current.nil? && current.id == id
    end
    @active
  end

  def start?
    !start_year.nil? && !start_month.nil?
  end

  def active_before_now?
    return false unless start?
    year, month = DateTime.current.year, DateTime.current.month
    (start_year == year && start_month <= month) ||
      start_year < year
  end

  class << self
    def current
      year, month = DateTime.current.year, DateTime.current.month
      active_before(year, month).first
    end
  end
end

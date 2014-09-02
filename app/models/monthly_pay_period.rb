class MonthlyPayPeriod < PayPeriod

  has_many :rank_achievements, foreign_key: :pay_period_id

  def type_display
    'Monthly'
  end

  def calculate!
    super
    self.rank_achievements.destroy_all
    create_rank_achievements!
  end

  def create_rank_achievements!
    records = []

    records = user_ids.inject([]) do |memo, id|
      memo + rank_achievements_for_user(id)
    end

    RankAchievement.create!(records)
    User.update_lifetime_ranks(self)
  end

  def ranks
    @ranks ||= Rank.with_qualifications.entries
  end

  def qualification_paths
    @qualification_paths ||= ranks.second.qualification_paths
  end

  def user_ids
    @user_ids ||= order_totals.map(&:user_id)
  end

  def genealogy
    @genealogy ||= User.select(:id, :upline, :lifetime_rank).with_parent(*user_ids).entries
  end

  def rank_achievements_for_user(user_id)
    attrs = []

    qualification_paths.each do |path|
      ranks[1..-1].each do |rank|
        qualifications = rank.grouped_qualifications[path]
        break if qualifications.nil? ||
          qualifications.any? { |q| !q.met?(user_id, self) }

        attrs << {
          achieved_at:    DateTime.current,
          pay_period_id:  self.id,
          user_id:        user_id,
          rank_id:        rank.id,
          path:           path }
      end
    end

    attrs
  end

  private

  class << self
    def id_from(date)
      date.strftime('%Y-%m')
    end

    def ids_from(date)
      now = DateTime.current
      diff = (now.year * 12 + now.month) - (date.year * 12 + date.month)
      (0...diff).map { |i| id_from(date + i.months) }
    end

    def find_or_create_by_id(id)
      find_or_create_by(id: id) do |period|
        period.start_date = Date.parse("#{id}-01")
        period.end_date = period.start_date.end_of_month
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end

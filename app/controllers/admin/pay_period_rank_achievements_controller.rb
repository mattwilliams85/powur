module Admin

  class PayPeriodRankAchievementsController < RankAchievementsController

    before_action :fetch_pay_period

    SORTS = {
      achieved_at:  :achieved_at,
      user:         'users.last_name asc' }

    sort_and_page available_sorts: SORTS

    private

    def fetch_pay_period
      pay_period = MonthlyPayPeriod.find(params[:pay_period_id])

      @rank_achievements = pay_period.rank_achievements
      @rank_achievements_path = pay_period_rank_achievements_path(pay_period)
    end

  end

end

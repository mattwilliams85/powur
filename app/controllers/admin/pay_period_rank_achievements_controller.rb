module Admin

  class PayPeriodRankAchievementsController < RankAchievementsController
    include ListQuery

    before_action :fetch_pay_period

    page
    sort  user: 'users.last_name asc, users.first_name asc',
          achieved_at: { achieved_at: :asc }

    private

    def fetch_pay_period
      pay_period = PayPeriod.find(params[:pay_period_id])

      @rank_achievements = pay_period.rank_achievements
      @rank_achievements_path = pay_period_rank_achievements_path(pay_period)
    end

  end

end

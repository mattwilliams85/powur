module Admin

  class PayPeriodRankAchievementsController < RankAchievementsController

    before_action :fetch_pay_period

    private

    def fetch_pay_period
      pay_period = MonthlyPayPeriod.find(params[:pay_period_id])

      @rank_achievements = pay_period.rank_achievements.
        includes(:rank, :user).references(:rank, :user).order(:user_id)
      @rank_achievements_path = pay_period_rank_achievements_path(pay_period)
    end

  end

end

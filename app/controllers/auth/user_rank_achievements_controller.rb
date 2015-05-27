module Auth
  class UserRankAchievementsController < RankAchievementsController
    before_action :fetch_user
    before_action :fetch_rank_achievements

    page
    sort achieved_at: { achieved_at: :asc }
    filter :pay_period,
           url:      -> { pay_periods_path },
           required: true,
           default:  -> { PayPeriod.last_id },
           name:     :title

    private

    def fetch_rank_achievements
      @rank_achievements = @user.rank_achievements
      @rank_achievements_path = user_rank_achievements_path(@user)
    end
  end
end

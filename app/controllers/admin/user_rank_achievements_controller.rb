module Admin
  class UserRankAchievementsController < RankAchievementsController
    before_action :fetch_user

    page
    sort achieved_at: { achieved_at: :asc }
    filter :pay_period,
           url:      -> { pay_periods_path },
           required: true,
           default:  -> { PayPeriod.last_id },
           name:     :title

    private

    def fetch_user
      user = User.find(params[:admin_user_id].to_i)

      @rank_achievements = user.rank_achievements
      @rank_achievements_path = admin_user_rank_achievements_path(user)
    end
  end
end

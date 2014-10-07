module Auth
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
      user = User.find_by(id: params[:user_id].to_i) ||
        not_found!(:user, params[:user_id])

      @rank_achievements = user.rank_achievements
      @rank_achievements_path = user_rank_achievements_path(user)
    end
  end
end

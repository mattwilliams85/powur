module Admin
  class UserRankAchievementsController < RankAchievementsController
    before_action :fetch_user
    before_action :fetch_rank_achievements

    page
    sort achieved_at: { achieved_at: :asc }
    filter :pay_period,
           url:     -> { pay_periods_path(calculated: true) },
           name:    :title,
           heading: 'lifetime'

    private

    def fetch_rank_achievements
      @rank_achievements = @user.rank_achievements
      if params[:pay_period].nil?
        @rank_achievements = @rank_achievements.lifetime
      end
      @rank_achievements_path = admin_user_rank_achievements_path(@user)
    end
  end
end

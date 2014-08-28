module Admin

  class UserRankAchievementsController < RankAchievementsController

    before_action :fetch_user

    private

    def fetch_user
      user = User.find(params[:admin_user_id].to_i)

      @rank_achievements = user.rank_achievements.
        includes(:rank).references(:rank).order(:pay_period_id)
      @rank_achievements_path = admin_user_rank_achievements_path(user)
    end

  end

end

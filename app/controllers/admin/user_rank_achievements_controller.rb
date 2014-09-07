module Admin

  class UserRankAchievementsController < RankAchievementsController

    before_action :fetch_user

    SORTS = {
      pay_period:  :pay_period_id,
      achieved_at: :achieved_at }

    sort_and_page available_sorts: SORTS

    private

    def fetch_user
      user = User.find(params[:admin_user_id].to_i)

      @rank_achievements = user.rank_achievements
      @rank_achievements_path = admin_user_rank_achievements_path(user)
    end

  end

end

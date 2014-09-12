module Auth

  class UserRankAchievementsController < RankAchievementsController

    before_action :fetch_user

    SORTS = {
      pay_period:  'pay_period_id desc, achieved_at asc',
    achieved_at: :achieved_at }

    sort_and_page available_sorts: SORTS

    private

    def fetch_user
      user = User.find(params[:user_id].to_i) or not_found!(:user, params[:user_id])

      @rank_achievements = user.rank_achievements
      @rank_achievements_path = user_rank_achievements_path(user)
    end

  end

end

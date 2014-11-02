module Admin
  class RankAchievementsController < AdminController
    helper RankAchievementsJson
    def index
      @rank_achievements = apply_list_query_options(
        @rank_achievements.includes(:rank, :user).references(:rank, :user))
    end
  end
end

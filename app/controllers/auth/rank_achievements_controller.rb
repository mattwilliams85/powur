module Auth

  class RankAchievementsController < AuthController

    def index
      @rank_achievements = page!(
        @rank_achievements.includes(:rank, :user).references(:rank, :user))
    end

  end

end

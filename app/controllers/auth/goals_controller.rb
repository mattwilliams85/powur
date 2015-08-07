module Auth
  class GoalsController < AuthController
    before_action :fetch_user
    before_action :fetch_rank

    def show
    end

    private

    def fetch_rank
      next_rank_id = @user.pay_as_rank + 1
      @next_rank = Rank.find_by(id: next_rank_id)
      return unless @next_rank

      @requirements = @next_rank.user_groups.map(&:requirements).flatten
    end
  end
end

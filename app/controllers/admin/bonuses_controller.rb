module Admin
  class BonusesController < AdminController
    before_action :fetch_bonus_plan, only: [ :index, :create ]
    before_action :fetch_bonus, only: [ :show, :update, :destroy ]

    def index
      @bonuses = @bonus_plan.bonuses.order(:created_at)

      render 'index'
    end

    def create
      require_input :type, :name

      @bonus = bonus_klass.create!(input.merge(bonus_plan_id: @bonus_plan.id))

      render 'show'
    end

    def show
    end

    def update
      @bonus.update_attributes!(input)

      if params[:amounts]
        amounts = params[:amounts].map(&:to_f)

        bonus_level = @bonus.default_bonus_level
        if bonus_level
          bonus_level.update_attributes(amounts: amounts)
        else
          @bonus.bonus_levels.create!(level: 0, amounts: amounts)
        end
      end

      render 'show'
    end

    def destroy
      @bonus_plan = @bonus.bonus_plan
      @bonus.destroy

      index
    end

    private

    def input
      allow_input(
        :name, :schedule, :use_rank_at, :achieved_rank_id, :max_user_rank_id,
        :min_upline_rank_id, :compress, :flat_amount)
    end

    def bonus_klass
      Bonus.symbol_to_type(params[:type])
    end

    def fetch_bonus_plan
      @bonus_plan = BonusPlan.find(params[:bonus_plan_id].to_i)
    end

    def fetch_bonus
      @bonus = Bonus.find(params[:id].to_i)
    end
  end
end

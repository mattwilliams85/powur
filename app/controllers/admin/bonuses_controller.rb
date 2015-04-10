module Admin
  class BonusesController < AdminController
    before_action :fetch_bonus_plan, only: [ :index, :create ]
    before_action :fetch_bonus, only: [ :show, :update, :destroy ]

    def index
      @bonuses = @bonus_plan ? @bonus_plan.bonuses : Bonus.all
      @bonuses = @bonuses.order('type')

      render 'index'
    end

    def create
      require_input :type, :name

      @bonus = bonus_klass.create!(input.merge(bonus_plan_id: @bonus_plan.id))

      show
    end

    def show
      render 'show'
    end

    def update
      @bonus.update_attributes!(input)

      show
    end

    def destroy
      @bonus_plan = @bonus.bonus_plan
      @bonus.destroy

      index
    end

    private

    def input
      allow_input(
        :name, :schedule, :compress, :time_period, :time_amount)
    end

    def bonus_klass
      params[:type].constantize
    end

    def fetch_bonus_plan
      return unless params[:bonus_plan_id]
      @bonus_plan = BonusPlan.find(params[:bonus_plan_id].to_i)
    end

    def fetch_bonus
      @bonus = Bonus.find(params[:id].to_i)
    end
  end
end

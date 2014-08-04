module Admin

  class BonusPlansController < AdminController

    before_filter :fetch_bonus_plan, only: [ :show, :destroy, :update ]

    def index
      @bonus_plans = BonusPlan.all.order(:name)

      render 'index'
    end

    def show
    end

    def update
      @bonus_plan.update_attributes!(input)

      render 'show'
    end

    def destroy
      @bonus_plan.destroy

      render 'index'
    end

    private

    def input
      allow_input(:start_year, :start_month)
    end

    def fetch_bonus_plan
      @bonus_plan = BonusPlan.find(params[:id].to_i)
    end

  end

end
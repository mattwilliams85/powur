module Admin

  class BonusPlansController < AdminController

    before_action :fetch_bonus_plan, only: [ :show, :destroy, :update ]

    def index
      @bonus_plans = BonusPlan.all.order(:name)

      render 'index'
    rescue ActiveRecord::RecordNotUnique
      duplicate_start_error!
    end

    def show
    end

    def create
      @bonus_plan = BonusPlan.create!(input)

      render 'show'
    end

    def update
      @bonus_plan.update_attributes!(input)

      render 'show'
    rescue ActiveRecord::RecordNotUnique
      duplicate_start_error!
    end

    def destroy
      @bonus_plan.destroy

      render 'index'
    end

    private

    def input
      allow_input(:name, :start_year, :start_month)
    end

    def fetch_bonus_plan
      @bonus_plan = BonusPlan.find(params[:id].to_i)
    end

    def duplicate_start_error!
      start_year, start_month = input['start_year'].to_i, input['start_month'].to_i
      plan = BonusPlan.where(start_year: start_year, start_month: start_month).first

      error! t('errors.duplicate_bonus_plan_start', plan: plan.name)
    end

  end

end
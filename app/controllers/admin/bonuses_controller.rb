module Admin

  class BonusesController < AdminController

    before_action :fetch_bonus, only: [ :show, :update, :destroy ]

    def index
      @bonuses = Bonus.all.order(:created_at)

      render 'index'
    end

    def create
      require_input :type, :name

      @bonus = bonus_klass.create!(input)

      render 'show'
    end

    def show
    end

    def update
      @bonus.update_attributes!(input)

      render 'show'
    end

    def destroy
      @bonus.destroy

      index
    end

    private

    def input
      allow_input(
        :name, :schedule, :achieved_rank_id, :max_user_rank_id,
        :min_upline_rank_id, :compress, :flat_amount)
    end

    def bonus_klass
      Bonus.symbol_to_type(params[:type])
    end

    def fetch_bonus
      @bonus = Bonus.find(params[:id].to_i)
    end

  end

end
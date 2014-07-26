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

      if params[:amounts]
        amounts = params[:amounts].map(&:to_f)

        bonus_level = @bonus.bonus_levels.where(level: 0).first
        if bonus_level
          bonus_level.update_attributes(amounts: amounts)
        else
          @bonus.bonus_levels.create!(level: 0, amounts: amounts)
        end
      end

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
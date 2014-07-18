module Admin

  class BonusesController < AdminController

    before_filter :fetch_bonus, only: [ :show, :update, :destroy ]

    def index
      @bonuses = Bonus.all.order(:created_at)

      render 'index'
    end

    def create
      require_input :name

      @bonus = Bonus.create!(input)

      render 'show'
    end

    def show
    end

    def update

      render 'show'
    end

    def destroy
      @bonus.destroy

      index
    end

    private

    def input
      allow_input(:name, :achieved_rank, :schedule, :pays, 
        :compress, :max_user_rank, :min_upline_rank, :compress, :levels, :flat_amount)
    end

    def fetch_bonus
      @bonus = Bonus.find(params[:id].to_i)
    end

  end

end
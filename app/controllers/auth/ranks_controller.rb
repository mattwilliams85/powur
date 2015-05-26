module Auth
  class RanksController < AuthController
    before_action :verify_admin, except: [ :index, :show ]
    before_action :fetch_rank, only: [ :show, :destroy, :update, :add_group ]

    def index
      @ranks = Rank.all

      render 'index'
    end

    def show
      render 'show'
    end

    def create
      require_input :title

      @rank = Rank.create!(input)

      render 'show'
    end

    def update
      require_input :title

      @rank.update_attributes!(input)

      render 'show'
    end

    def destroy
      error!(:delete_rank) unless @rank.last?

      @rank.destroy

      index
    end

    private

    def input
      allow_input(:title)
    end

    def fetch_rank
      @rank = Rank.find(params[:id].to_i)
    end

  end
end
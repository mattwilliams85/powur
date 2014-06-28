module Admin

  class RanksController < AdminController

    before_filter :fetch_rank, only: [ :show, :destroy ]

    def index
      @ranks = Rank.all.includes(:qualifications).order(:id)

      render 'index'
    end

    def show
    end

    def create
      require_input :title

      @rank = Rank.create!(allow_input(:title))
      
      render 'show'
    end

    def update
    end

    def destroy
      error!(t('errors.delete_rank')) unless @rank.last_rank?

      @rank.destroy

      index
    end

    private

    def fetch_rank
      @rank = Rank.find(params[:id].to_i)
    end

  end

end
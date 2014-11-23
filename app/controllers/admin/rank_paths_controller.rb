module Admin
  class RankPathsController < AdminController
    before_action :fetch_rank_path, only: [ :show, :destroy, :update ]

    def index
      @rank_paths = RankPath.all.order(:name)

      render 'index'
    end

    def create
      RankPath.create!(input)

      index
    end

    def update
      require_input :name

      @rank_path.update_attributes!(input)

      index
    end

    def destroy
      @rank_path.destroy

      index
    end

    private

    def input
      allow_input(:name, :description)
    end

    def fetch_rank_path
      @rank_path = RankPath.find(params[:id].to_i)
    end
  end
end

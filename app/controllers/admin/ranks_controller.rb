module Admin
  class RanksController < AdminController
    helper QualificationsJson

    before_action :fetch_rank, only: [ :show, :destroy, :update ]

    def index
      @ranks = Rank.all.includes(qualifications: [ :product ])

      render 'index'
    end

    def show
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
      error!(t('errors.delete_rank')) unless @rank.last_rank?

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

module Auth
  class UserGroupsController < AuthController
    before_action :verify_admin, except: [ :index, :show ]
    before_action :fetch_group, only: [ :show, :update, :destroy, :add_to_rank ]
    before_action :fetch_rank, only: [ :index, :add_to_rank ]

    def index
      @groups = UserGroup.order(:id)
      if @rank
        @groups = @groups
          .joins(:ranks_user_groups)
          .where(ranks_user_groups: { rank_id: @rank })
      end

      render 'index'
    end

    def show
      render 'show'
    end

    def create
      @user_group = UserGroup.create!(input.merge(id: params[:id]))

      show
    end

    def update
      @user_group.update_attributes!(input)

      show
    end

    def destroy
      @user_group.destroy

      index
    end

    def add_to_rank
      @groups = @rank.user_groups << @user_group

      render 'index'
    end

    private

    def fetch_group
      @user_group = UserGroup.find(params[:id])
    end

    def fetch_rank
      rank_id = params[:rank] || params[:rank_id]
      return unless rank_id
      @rank = Rank.find(rank_id.to_i)
    end

    def input
      allow_input(:title, :description)
    end
  end
end

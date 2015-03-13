module Admin
  class UserGroupsController < AdminController
    before_action :fetch_group, only: [ :show, :update, :destroy ]

    def index
      @groups = UserGroup.order(:id)

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

    private

    def fetch_group
      @user_group = UserGroup.find(params[:id])
    end

    def input
      allow_input(:title, :description)
    end
  end
end

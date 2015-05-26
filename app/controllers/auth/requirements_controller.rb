module Auth
  class RequirementsController < AuthController
    before_action :verify_admin, except: [ :index, :show ]
    before_action :fetch_user_group, only: [ :index, :create ]
    before_action :fetch_requirement, only: [ :show, :update, :destroy ]

    def index
      @requirements = @user_group.requirements

      render 'index'
    end

    def show
    end

    def create
      @requirement = @user_group.requirements.create!(create_input)

      render 'show'
    end

    def update
      @requirement.update_attributes!(update_input)

      render 'show'
    end

    def destroy
      @user_group = @requirement.user_group
      @requirement.destroy

      index
    end

    private

    def create_input
      allow_input(:product_id, :quantity)
    end

    def update_input
      allow_input(:quantity, :time_span, :max_leg)
    end

    def fetch_user_group
      @user_group = UserGroup.find(params[:user_group_id])
    end

    def fetch_requirement
      @requirement = UserGroupRequirement.find(params[:id])
    end
  end
end

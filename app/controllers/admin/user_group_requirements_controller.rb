module Admin
  class UserGroupRequirementsController < AdminController
    before_action :fetch_requirement, only: [ :update, :destroy ]

    def create
      @user_group = UserGroup.find(params[:user_group_id])
      @user_group.requirements.create!(input)

      head 200
    end

    def update
      @requirement.update_attributes!(input)

      render 'show'
    end

    def destroy
      @requirement.destroy

      head 200
    end

    private

    def input
      allow_input(:product_id, :event_type, :quantity)
    end

    def fetch_requirement
      @requirement = UserGroupRequirement.find(params[:id])
      @user_group = @requirement.user_group
    end

    class << self
      def controller_path
        'admin/user_groups'
      end
    end
  end
end

module Admin
  class OverridesController < AdminController
    before_action :fetch_user, only: [ :index, :create ]
    before_action :fetch_override, only: [ :update, :destroy ]
    sort start_date: :start_date,
         user:       'users.last_name asc, users.first_name asc'

    def index
      @overrides = params[:admin_user_id] ? @user.overrides : UserOverride.all
      @overrides = apply_list_query_options(@overrides)
                   .includes(:user).references(:user)

      render 'index'
    end

    def create
      @user.overrides.create!(input.merge(allow_input(:kind)))

      index
    end

    def update
      @override.update_attributes!(input)

      index
    end

    def destroy
      @override.destroy

      index
    end

    private

    def input
      attrs = allow_input(:start_date, :end_date)
      # Setting override data based on the kind
      case params[:kind]
      when 'pay_as_rank'
        attrs[:data] = { rank: params[:value] }
      end
      attrs
    end

    def fetch_override
      @override = UserOverride.find(params[:id].to_i)
    end
  end
end

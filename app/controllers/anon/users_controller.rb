module Anon
  class UsersController < AnonController
    before_action :fetch_user,
                  :increment_solar_landing_view_count, only: [ :show ]

    private

    def fetch_user
      @user = User.find_by(id: params[:id])
      not_found!(:user) if @user.nil?
    end

    def increment_solar_landing_view_count
      count = (@user.solar_landing_views_count || 0).to_i
      @user.update_attribute(:solar_landing_views_count, count + 1)
    end
  end
end

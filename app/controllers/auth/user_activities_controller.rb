module Auth
  class UserActivitiesController < AuthController
    before_action :fetch_user

    page
    sort pay_period: { pay_period_id: :desc },
         personal:   { personal: :desc }

    private

    def fetch_user
      user = User.find(params[:user_id].to_i)
      @user_activities = user.user_activities
    end
  end
end

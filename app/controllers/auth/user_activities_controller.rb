module Auth
  class UserActivitiesController < AuthController
    before_action :fetch_user
    before_action :fetch_activities

    page
    sort pay_period: { pay_period_id: :desc },
         personal:   { personal: :desc }

    private

    def fetch_activities
      @user_activities = @user.user_activities
    end
  end
end

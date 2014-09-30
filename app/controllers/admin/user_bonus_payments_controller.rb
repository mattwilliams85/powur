module Admin

  class UserBonusPaymentsController < BonusPaymentsController

    before_action :fetch_user

    filter :pay_period, url: ->{ pay_periods_path }

    SORTS = {
      pay_period_id: 'pay_period_id desc, 
      bonus_payments.created_at asc' }

    sort_and_page available_sorts: SORTS

    private

    def fetch_user
      user = User.find(params[:admin_user_id].to_i)
      @bonus_payments = apply_scopes(user.bonus_payments)
      @bonus_payments_path = admin_user_bonus_payments_path(user)
    end

  end

end

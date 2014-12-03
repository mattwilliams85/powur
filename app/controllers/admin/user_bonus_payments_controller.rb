module Admin
  class UserBonusPaymentsController < BonusPaymentsController
    before_action :fetch_user

    page
    sort created_at: 'bonus_payments.created_at asc'
    filter :pay_period,
           url:      -> { pay_periods_path(calculated: true) },
           required: true,
           default:  -> { PayPeriod.last_id },
           name:     :title
    filter :bonus,
           options:  -> { Hash[Bonus.all.map { |b| [ b.id.to_i, b.name ] }] },
           required: false

    private

    def fetch_user
      user = User.find(params[:admin_user_id].to_i)
      @bonus_payments = user.bonus_payments
      @bonus_payments_path = admin_user_bonus_payments_path(user)
    end
  end
end

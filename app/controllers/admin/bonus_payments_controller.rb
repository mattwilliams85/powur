module Admin

  class BonusPaymentsController < AdminController

    def index
      @bonus_payments = page!(
        @bonus_payments.includes(:user).references(:user))
    end

  end

end

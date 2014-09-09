module Admin

  class BonusPaymentsController < AdminController

    def index
      @bonus_payments = page!(
        @bonus_payments.includes(:user, :bonus).references(:user, :bonus))
    end

  end

end

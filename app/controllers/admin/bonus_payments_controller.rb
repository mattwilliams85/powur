module Admin

  class BonusPaymentsController < AdminController

    def index
      @bonus_payments = apply_list_query_options(@bonus_payments).
        includes(:user, :bonus).references(:user, :bonus)
    end

  end

end

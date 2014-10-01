module Admin

  class BonusPaymentsController < AdminController

    def index
      @bonus_payments = apply_list_query_options(@bonus_payments).
        includes(:user, :bonus).references(:user, :bonus)
      total_amount = @bonus_payments.except(:offset, :limit, :order).sum(:amount)
      @totals = {
        amount: total_amount }
    end

  end

end

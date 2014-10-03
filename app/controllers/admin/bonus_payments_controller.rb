module Admin
  class BonusPaymentsController < AdminController
    def index
      total_amount = @bonus_payments.except(:offset, :limit, :order)
        .sum(:amount)
      @totals = [ { name: 'Bonus Total', value: total_amount } ]

      @bonus_payments = apply_list_query_options(@bonus_payments)
        .includes(:user, :bonus).references(:user, :bonus)
    end
  end
end

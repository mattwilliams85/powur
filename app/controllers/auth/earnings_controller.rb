module Auth
  class EarningsController < AuthController
    def show
      @user = current_user
      @downline = @user.downline_users
      @total_earnings = current_user.bonus_payments.sum(:amount) 
      @downline.each do |user|
        @total_earnings += user.bonus_payments.sum(:amount)
      end
      

      # @total_amount = @bonus_payments
      #  .except(:offset, :limit, :order).sum(:amount)
    end
  end
end

# def index
#       total_amount = @bonus_payments
#                      .except(:offset, :limit, :order).sum(:amount)
#       @totals = [ { id: :bonus, value: total_amount, type: :currency } ]

#       @bonus_payments = apply_list_query_options(@bonus_payments)
#                         .includes(:user, :bonus).references(:user, :bonus)
#     end
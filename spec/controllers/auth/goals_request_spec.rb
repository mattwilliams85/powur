require 'spec_helper'

describe '/u/users/:user_id/goals', type: :request do

  before :each do
    login_user
    @pay_period = MonthlyPayPeriod.current
  end

  it 'returns the current users goals' do
    create_list(:rank, 2)
    sales_qual = create(:sales_qualification, rank_id: 2,
                        time_period: :monthly, quantity: 10)
    product = sales_qual.product
    create(
      :group_sales_qualification,
      rank_id:     2,
      time_period: :monthly,
      product:     product,
      quantity:    20)

    create(:order_total, user: @user, pay_period: @pay_period, product: product)

    get user_goals_path(@user), format: :json

    # binding.pry
  end

end

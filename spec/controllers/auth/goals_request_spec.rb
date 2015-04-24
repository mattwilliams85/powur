require 'spec_helper'

describe '/u/users/:user_id/goals', type: :request do

  before do
    login_user
    @pay_period = MonthlyPayPeriod.current
    create_list(:rank, 3)
    sales_qual = create(:sales_qualification, rank_id: 2,
                        time_period: :monthly, quantity: 10)
    @product = sales_qual.product
    create(
      :group_sales_qualification,
      rank_id:     2,
      time_period: :monthly,
      product:     @product,
      quantity:    20)
  end

  it 'returns the current users goals' do
    create(:order_total,
           user:       @user,
           pay_period: @pay_period,
           product:    @product)

    get user_goals_path(@user), format: :json

    ranks = json_body['entities'].find { |e| e['rel'].include?('goals-ranks') }
    expect(ranks).to be
    rank = ranks['entities'].find { |r| r['properties']['id'] == 2 }
    expect(rank).to be
  end

  it 'works when the user has no order totals' do
    get user_goals_path(@user), format: :json

    totals = json_body['entities']
             .find { |e| e['rel'].include?('goals-order_totals') }
    expect(totals).to be
    expect(totals['entities'].size).to eq(0)
  end

end

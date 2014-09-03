require 'spec_helper'

describe MonthlyPayPeriod, type: :model do

  describe '::ids_from' do

    it 'returns last months id if first order is a month ago' do
      from = Date.current - 1.month
      ids = MonthlyPayPeriod.ids_from(from)
      expect(ids.size).to eq(1)
      expect(ids.first).to eq(from.strftime('%Y-%m'))
    end

    it 'works across years' do
      from = Date.current - 1.year
      ids = MonthlyPayPeriod.ids_from(from)
      expect(ids.size).to eq(12)
    end

  end

  describe '::find_or_create_by_id' do

    it 'creates a new pay period from an id value' do
      id = '2014-08'
      pay_period = MonthlyPayPeriod.find_or_create_by_id(id)

      expected = Date.new(2014, 8, 1)
      expect(pay_period.start_date).to eq(expected)
      expect(pay_period.end_date).to eq(expected.end_of_month)
      expect(pay_period.calculated?).to_not be
    end

  end

  describe '#calculate' do

    before :each do
      create_list(:rank, 5)
      @user = create(:user)
      @children = create_list(:user, 2, sponsor: @user)
      @product = create(:product)
      @order_date = DateTime.current - 1.month
    end

    def create_order(user, quantity = 1)
      order = create(:order,
        product:    @product,
        user:       user,
        order_date: @order_date,
        quantity:   quantity)
    end


    it 'generates rank achievements' do
      create(:sales_qualification,
        product: @product, quantity: 3, rank_id: 2, time_period: :monthly)
      create(:group_sales_qualification,
        product: @product, quantity: 6, rank_id: 3, time_period: :monthly, max_leg_percent: 70)
      create(:sales_qualification,
        product: @product, quantity: 5, rank_id: 4, time_period: :lifetime)
      create(:group_sales_qualification,
        product: @product, quantity: 10, rank_id: 4, time_period: :monthly, max_leg_percent: 70)
      order_date = DateTime.current - 1.month
      order = create_order(@user)
      create_order(@user, 5)
      create_order(@children.first, 7)
      create_order(@children.last, 3)

      period = order.monthly_pay_period
      period.calculate!

      expect(period.rank_achievements.count).to eq(5)
      user_ranks = period.rank_achievements.where(user_id: @user.id)
      expect(user_ranks.count).to eq(3)

      expect(User.find(@user.id).lifetime_rank).to eq(4)
      expect(User.find(@children.first.id).lifetime_rank).to eq(2)
      expect(User.find(@children.last.id).lifetime_rank).to eq(2)
    end
  end

end

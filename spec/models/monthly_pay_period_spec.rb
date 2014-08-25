require 'spec_helper'

describe MonthlyPayPeriod, type: :model do

  describe '::ids_from' do

    it 'returns an empty array if the date is within the current month' do
      ids = MonthlyPayPeriod.ids_from(Date.current - 1.minute)
      expect(ids).to be_empty
    end

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
      create_list(:rank, 3)
      @user = create(:user)
      @children = create_list(:user, 2, sponsor: @user)
    end

    it 'generates rank achievements' do
      product = create(:product)
      qualification = create(:sales_qualification, 
        product:  product,
        quantity: 3,
        rank_id:  1,
        period:   :pay_period)
      order_date = DateTime.current - 1.month
      create(:order,
        product:    product,
        user:       @user,
        order_date: order_date)
      order = create(:order,
        product:    product,
        user:       @user,
        order_date: order_date,
        quantity:   2)
      order = create(:order,
        product:    product,
        user:       @children.first,
        order_date: order_date,
        quantity:   1)
      order = create(:order,
        product:    product,
        user:       @children.last,
        order_date: order_date,
        quantity:   1)

      # orders = Order.group_sales(@user.id)
      # period = order.monthly_pay_period
      # expect(period.user_product_orders.size).to eq(1)
      # aggregate_order = period.user_product_orders.first
      # expect(aggregate_order.quantity).to eq(3)
      # expect(aggregate_order.product_id).to eq(product.id)
    end
  end

end

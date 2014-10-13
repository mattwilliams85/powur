require 'spec_helper'

describe Order, type: :model do

  it 'searches by user' do
    user = create(:user, first_name: 'Garey')
    create(:order, user: user)
    user = create(:user, first_name: 'Garry')
    create(:order, user: user)
    3.times.each { create(:order, user: create(:search_miss_user)) }

    results = Order.user_search('gary').entries
    expect(results.size).to eq(2)
  end

  it 'searches by customer' do
    customer = create(:customer, first_name: 'Garey')
    create(:order, customer: customer)
    customer = create(:customer, first_name: 'Garry')
    create(:order, customer: customer)
    3.times.each { create(:order, customer: create(:search_miss_customer)) }

    results = Order.customer_search('gary').entries
    expect(results.size).to eq(2)
  end

  it 'searches by user and customer' do
    user = create(:user, first_name: 'Garey')
    create(:order, user: user)
    customer = create(:customer, last_name: 'Garry')
    create(:order, customer: customer)

    3.times.each { create(:order, user: create(:search_miss_user)) }

    results = Order.user_customer_search('gary').entries
    expect(results.size).to eq(2)
  end

  describe '#monthly_pay_period' do

    it 'creates a pay period if one does not exist' do
      order = create(:order)
      expect(order.monthly_pay_period).to_not be_nil
      expect(order.monthly_pay_period).to be_kind_of(MonthlyPayPeriod)
      expect(order.monthly_pay_period.start_date).to be <= order.order_date
      expect(order.monthly_pay_period.end_date + 1.day)
        .to be >= order.order_date
    end
  end

  describe '::group_sales' do

    it 'returns the group sales aggregate' do
      root = create(:user)
      parent = create(:user, sponsor: root)
      children = create_list(:user, 2, sponsor: parent)

      product1 = create(:product)

      order_date1 = DateTime.current - 3.months
      create_list(:order, 1,
                  user:       parent,
                  product:    product1,
                  order_date: order_date1)
      create_list(:order, 2,
                  user:       children.first,
                  product:    product1,
                  order_date: order_date1)
      create_list(:order, 3,
                  user:       children.last,
                  product:    product1,
                  order_date: order_date1)

      totals = Order.group_totals(order_date1 + 1.month)
      { root           => 6,
        parent         => 6,
        children.first => 2,
        children.last  => 3 }.each do |user, total|
        order_total = totals.find { |o| o.user_id == user.id }
        expect(order_total).to_not be_nil
        expect(order_total.quantity).to eq(total)
      end

      order_date2 = DateTime.current - 1.month
      create_list(:order, 2,
                  user:       parent,
                  product:    product1,
                  order_date: order_date2)
      create_list(:order, 4,
                  user:       children.first,
                  product:    product1,
                  order_date: order_date2)
      create_list(:order, 6,
                  user:       children.last,
                  product:    product1,
                  order_date: order_date2)

      totals = Order.group_totals(order_date2 + 1.month)
      { root           => 18,
        parent         => 18,
        children.first => 6,
        children.last  => 9 }.each do |user, total|
        order_total = totals.find { |o| o.user_id == user.id }
        expect(order_total).to_not be_nil
        expect(order_total.quantity).to eq(total)
      end
    end
  end

end

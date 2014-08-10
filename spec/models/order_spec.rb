require 'spec_helper'

describe Order, type: :model do

  it 'searches by user' do
    user = create(:user, first_name: 'Garey')
    create(:order, user: user)
    user = create(:user, first_name: 'Garry')
    create(:order, user: user)
    create_list(:order, 3)

    results = Order.user_search('gary').entries
    expect(results.size).to eq(2)
  end

  it 'searches by customer' do
    customer = create(:customer, first_name: 'Garey')
    create(:order, customer: customer)
    customer = create(:customer, first_name: 'Garry')
    create(:order, customer: customer)
    create_list(:order, 3)

    results = Order.customer_search('gary').entries
    expect(results.size).to eq(2)
  end

  it 'searches by user and customer' do
    user = create(:user, first_name: 'Garey')
    create(:order, user: user)
    customer = create(:customer, last_name: 'Garry')
    create(:order, customer: customer)
    create_list(:order, 3)

    results = Order.user_customer_search('gary').entries
    expect(results.size).to eq(2)
  end

end

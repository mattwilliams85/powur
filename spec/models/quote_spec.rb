require 'spec_helper'

describe Quote, type: :model do
  it 'does not allow data not defined for the product' do
    expect { create(:quote, data: { 'foo' => 'bar' }) }
      .to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'allows data defined for the product' do
    product = create(:product, quote_data: %w(foo bar))

    data = { 'foo' => 'joy', 'bar' => 'galore' }
    create(:quote, product: product, data: data)
  end

  it 'searches quotes through the customer' do
    customer = create(:customer, first_name: 'Garey')
    create(:quote, customer: customer)
    create(:quote, customer: create(:customer, first_name: 'Joe'))

    results = Quote.joins(:customer).customer_search('gary')
    expect(results.size).to eq(1)
    expect(results.first.customer.id).to eq(customer.id)
  end
end

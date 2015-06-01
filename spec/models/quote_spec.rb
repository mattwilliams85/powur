require 'spec_helper'

describe Quote, type: :model do
  it 'does not allow data not defined for the product' do
    create(:product_with_quote_fields)
    data = { 'foo' => 'joy', 'bar' => 'galore' }
    expect { create(:quote, data: data) }
      .to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'allows data defined for the product' do
    product = create(:product_with_quote_fields)
    data = Hash[product.quote_field_keys.map { |n| [ n, 'foo' ] }]
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

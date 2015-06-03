require 'spec_helper'

describe Quote, type: :model do
  it 'does not allow data not defined for the product' do
    product = create(:product_with_quote_fields)
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

  describe '#calculate_status' do
    subject { quote.status }
    let(:customer) { create(:customer) }
    let(:quote) { create(:quote, customer: customer) }

    context 'proposal submitted' do
      before do
        allow_any_instance_of(Quote).to receive(:submitted_at?).and_return(true)
        quote
      end
      it { is_expected.to eq 'submitted' }
    end

    context 'proposal ready to submit' do
      before do
        allow_any_instance_of(Quote).to receive(:can_submit?).and_return(true)
        allow_any_instance_of(Quote).to receive(:zip_code_valid?).and_return(true)
        allow_any_instance_of(Quote).to receive(:submitted?).and_return(false)
        quote
      end
      it { is_expected.to eq 'ready_to_submit' }
    end

    context 'proposal has ineligible location' do
      before do
        allow_any_instance_of(Quote).to receive(:can_submit?).and_return(true)
        allow_any_instance_of(Quote).to receive(:zip_code_valid?).and_return(false)
        allow_any_instance_of(Quote).to receive(:submitted?).and_return(false)
        quote
      end
      it { is_expected.to eq 'ineligible_location' }
    end

    context 'proposal incomplete' do
      before do
        allow_any_instance_of(Quote).to receive(:can_submit?).and_return(false)
        allow_any_instance_of(Quote).to receive(:zip_code_valid?).and_return(true)
        allow_any_instance_of(Quote).to receive(:submitted?).and_return(false)
        quote
      end
      it { is_expected.to eq 'incomplete' }
    end
  end

end

require 'spec_helper'

describe QuoteSubmission, type: :model do
  def assert_submit(quote, cassette)
    VCR.use_cassette("quotes/#{cassette}") { quote.submit! }
    expect(quote.submitted_at).to be
  end

  describe 'good data' do
    it 'records the provider uid' do
      quote = create(:complete_quote, id: 43)
      assert_submit(quote, 'success')
    end

    xit 'sends lots of quote submissions' do
      VCR.use_cassette('quotes/many') do
        1.upto(200).each do |i|
          quote = create(:complete_quote, id: 500+i)
          quote.submit!
          expect(quote.submitted_at).to be
          expect(quote.provider_uid).to be
        end
      end
    end
  end

  describe 'existing lead' do
    it 'records the partial provider uid on a duplicate submission' do
      quote = create(:complete_quote, id: 43)
      assert_submit(quote, 'exists')
    end
  end

  describe 'INVALID missing data' do
    it 'fails without an email' do
      customer = create(:customer, email: nil)
      quote = create(:quote, id: 211, customer: customer)
      expect { quote.submit! }.to raise_error(RuntimeError)
    end

    it 'fails without a phone' do
      customer = create(:customer, phone: nil)
      quote = create(:quote, id: 212, customer: customer)
      expect { quote.submit! }.to raise_error(RuntimeError)
    end
  end

  describe 'OK missing data' do
    it 'submits without an electric bill' do
      quote = create(:quote, id: 210)
      assert_submit(quote, 'no_electric_bill')
    end

    it 'submits without a postal code' do
      customer = create(:customer, zip: nil)
      quote = create(:quote, id: 213, customer: customer)
      assert_submit(quote, 'no_zip')
    end

    it 'submits without a city' do
      customer = create(:customer, city: nil)
      quote = create(:quote, id: 214, customer: customer)
      assert_submit(quote, 'no_city')
    end

    it 'submits without an address' do
      customer = create(:customer, address: nil)
      quote = create(:quote, id: 215, customer: customer)
      assert_submit(quote, 'no_street')
    end
  end
end

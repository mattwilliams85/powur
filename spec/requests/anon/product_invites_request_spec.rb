require 'spec_helper'

describe '/product_invites/:customer_code' do
  describe '#show' do
    let(:code) { 'qwerty' }
    let(:user) { create(:user) }
    let!(:customer) { create(:customer, code: code, user: user) }

    it 'returns customer data' do
      get product_invite_path(customer.code), format: :json

      expect_200
      expect_props(first_name: customer.first_name)
      expect_actions('validate_zip')
    end
  end

  describe '#update' do
    let(:code) { 'qwerty' }
    let(:user) { create(:user) }
    let!(:customer) { create(:customer, code: code, user: user) }
    let!(:product) { create(:product) }
    let!(:quote_field) do
      create(:quote_field, name: 'average_bill', product: product)
    end
    let(:payload) do
      { first_name:   'Donald',
        last_name:    'Duck',
        email:        'donald@duck.com',
        phone:        '911',
        address:      '123 Main St',
        city:         'Sunnyvalley',
        state:        'OR',
        zip:          '90210',
        average_bill: '123' }
    end
    let(:solar_city_form) do
      double(:solar_city_form,
             post:         true,
             error?:       false,
             provider_uid: 1,
             response:     double(headers: { date: Time.zone.today.to_s }))
    end

    before do
      allow(Product).to receive(:default).and_return(product)
      allow(SolarCityForm).to receive(:new).and_return(solar_city_form)
      allow_any_instance_of(Lead).to receive(:email_customer).and_return(true)
    end

    it 'returns lead data' do
      VCR.use_cassette('zip_validation/valid') do
        patch product_invite_path(customer.code), payload

        expect_200
        expect_props(
          data_status:    'submitted',
          customer:       payload[:first_name] + ' ' + payload[:last_name],
          email:          payload[:email],
          product_fields: { 'average_bill' => payload[:average_bill] })
      end
    end
  end
end

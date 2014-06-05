require 'spec_helper'

describe '/customers' do

  before :each do
    login_user
  end

  describe '#index' do

    it 'returns the list of customers for a promoter' do
      create_list(:customer, 7, promoter: @user)

      get customers_path, format: :json
      expect_classes('list', 'customers')
      expect_actions('create')
    end

  end

  describe '#create' do

    let(:customer_params) {{
      email:      'newcustomer@example.org',
      first_name: 'Big',
      last_name:  'Money',
      city:       'SunnyVille',
      state:      'FL',
      zip:        '65999',
      format:     :json }}

    it 'creates a new customer' do
      post customers_path, customer_params

      expect_200
      expect_classes 'customer'
    end

  end

  describe '#show' do

    it 'returns not found with an invalid user id' do
      get customer_path(42), format: :json

      expect_alert_error
    end

    it 'returns a customer detail' do
      customer = create(:customer, promoter: @user)

      get customer_path(customer), format: :json

      expect_200
      expect_classes 'customer'
    end

  end

  describe '#update' do

    it 'updates an existing customer' do

    end
  end

end
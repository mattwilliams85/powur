require 'spec_helper'

describe '/a/orders' do

  before :each do
    login_user
  end

  describe 'POST /' do

    it 'creates an order from a quote' do
      quote = create(:quote)

      post orders_path, quote_id: quote.id, format: :json

      expect_classes 'order'
    end

    it 'does not allow an order to be created when one already exists for a quote' do
      order = create(:order)

      post orders_path, quote_id: order.quote_id, format: :json

      expect_alert_error
    end
  end
end
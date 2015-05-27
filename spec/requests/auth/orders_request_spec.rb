require 'spec_helper'

describe '/u/users/:id/orders' do

  before do
    login_user(auth: true)
  end

  describe 'GET /' do

    it 'returns not found with an invalid user id' do
      get user_quote_path(42), format: :json

      expect_alert_error
    end

    it 'renders orders for a user' do
      create_list(:order, 3, user: @user)
      create(:order)

      get user_orders_path(@user), format: :json
      expect_entities_count(3)
    end

    it 'does not allow a request for orders not in the users downline' do
      user = create(:user)
      @user.update_attributes!(roles: [])

      get user_orders_path(user), format: :json

      expect(response.status).to eq(404)
    end

    it 'filters orders on status' do
      create_list(:order, 2, user: @user, status: :closed)
      create(:order, user: @user, status: :cancelled)

      get user_orders_path(@user), status: 1, format: :json

      expect_entities_count(2)
    end
  end
end

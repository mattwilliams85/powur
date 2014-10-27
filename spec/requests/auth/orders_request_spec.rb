require 'spec_helper'

describe '/u/users/:id/orders' do

  before :each do
    login_user
  end

  describe 'GET /' do

    it 'returns not found with an invalid user id' do
      get user_quote_path(42), format: :json

      expect_alert_error
    end

    it 'renders orders for a user' do
      create(:order, user: @user)
      user = create(:user)
      create_list(:order, 3, user: user)

      get user_orders_path(user), format: :json

      expect_entities_count(3)
    end

    it 'filters orders on status' do
      create_list(:order, 2, user: @user, status: :closed)
      create(:order, user: @user, status: :cancelled)

      get user_orders_path(@user), status: 1, format: :json

      expect_entities_count(2)
    end
  end
end

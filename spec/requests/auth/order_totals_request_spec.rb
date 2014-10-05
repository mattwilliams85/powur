require 'spec_helper'

describe 'order totals', type: :request do

  before :each do
    login_user
  end


  describe '/u/users/:id/order_totals' do

    before :each do
      @user = create(:user)
    end

    it 'returns a list of order totals for the user' do
      create_list(:order_total, 3, user: @user)
      create(:order_total)

      get user_order_totals_path(@user), format: :json

      expect_entities_count(3)
    end

    it 'sorts order totals' do
      [ 3, 8, 5 ].each { |i| create(:order_total, user: @user, personal: i) }

      get user_order_totals_path(@user), format: :json, sort: :personal

      result = json_body['entities'].map { |e| e['properties']['personal'] }

      expect(result).to eq([ 8, 5, 3 ])
    end

    it 'pages order totals' do

      create_list(:order_total, 5, user: @user)

      get user_order_totals_path(@user), format: :json, limit: 3
      expect_entities_count(3)

      get user_order_totals_path(@user), format: :json, limit: 3, page: 2
      expect_entities_count(2)
    end
  end
end

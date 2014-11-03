require 'spec_helper'

describe '/u/users' do

  before :each do
    login_user
  end

  describe '#index' do

    it 'returns a list of the users belonging to the current user' do
      create_list(:user, 8, sponsor: @user)

      get users_path, format: :json

      expect_200
      expect_classes('users', 'list')
      expect(json_body['entities'].size).to eq(8)
    end

    it 'returns the users team sorted by group monthly count' do
      pay_period = MonthlyPayPeriod.current
      product = create(:default_product)

      totals = 1.upto(3).map do |i|
        user = create(:user, sponsor: @user)
        create(:order_total,
               user:       user,
               product:    product,
               pay_period: pay_period)
      end
      totals.sort_by(&:group).reverse.map(&:user_id)

      get users_path,
          'performance[metric]' => 'group',
          'performance[period]' => 'monthly',
          format:                  :json

      result = json_body['entities']
        .map { |e| e['properties']['id'] }

      expected = totals.sort_by(&:group).reverse.map(&:user_id)
      expect(result).to eq(expected)
    end

    it 'returns the users team sorted by quote count' do
      users = [ rand(5) + 1, rand(5) + 1, rand(5) + 1 ].map do |count|
        user = create(:user, sponsor: @user)
        create_list(:quote, count, user: user)
      end

      get users_path,
          'performance[metric]' => 'quotes',
          'performance[period]' => 'lifetime',
          format: :json

      result = json_body['entities']
        .map { |e| e['properties']['quote_count'] }

      expect(result).to eq(result.sort.reverse)
    end

  end

  describe '#search' do

    it 'searches a list of users belong to the current user' do
      user1 = create(:user, sponsor: @user, first_name: 'davey')
      user2 = create(:user, sponsor: @user, last_name: 'david')
      user3 = create(:user, sponsor: @user, email: 'redave@example.org')
      create_list(:user, 2, sponsor: @user, first_name: 'Mary',
                  last_name: 'Jones')

      get users_path, search: 'dave', format: :json

      expect(json_body['entities'].size).to eq(3)
      result_ids = json_body['entities'].map { |u| u['properties']['id'] }

      expect(result_ids).to include(user1.id, user2.id, user3.id)
    end

  end

  describe '/:id' do

    it 'returns not found with an invalid user id' do
      get user_path(42), format: :json

      expect_alert_error
    end

    it 'returns the user detail' do
      user = create(:user, sponsor: @user)
      get user_path(user), format: :json

      expect_200
    end

  end

  describe '/u/users/:id/downline' do
    it 'returns the downline users' do
      child = create_list(:user, 3, sponsor: @user).first

      create_list(:user, 2, sponsor: child)

      get downline_user_path(@user), format: :json

      expect_200

      found_child = json_body['entities']
                    .find { |e| e['properties']['id'] == child.id }
      expect(found_child).to_not be_nil
      expect(found_child['properties']['downline_count']).to eq(2)
    end
  end

  describe '/u/users/:id/upline' do
    it 'returns the upline users' do
      grand_parent = create(:user, sponsor: @user, first_name: 'Pappy')
      parent = create(:user, sponsor: grand_parent, first_name: 'Parent')
      child = create(:user, sponsor: parent, first_name: 'Child')

      get upline_user_path(child), format: :json

      expect_200

      found_parent = json_body['entities']
                    .find { |e| e['properties']['id'] == parent.id }
      found_grand_parent = json_body['entities']
                          .find { |e| e['properties']['id'] == grand_parent.id }
      expect(found_parent).to_not be_nil
      expect(found_grand_parent).to_not be_nil
      expect(json_body['entities'].count).to eq(3)
    end
  end

end

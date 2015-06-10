require 'spec_helper'

describe '/u/users' do
  let!(:current_user) { login_user(auth: true, roles: []) }

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

      totals = 1.upto(3).map do
        user = create(:user, sponsor: @user)
        create(:order_total,
               user:       user,
               product:    product,
               pay_period: pay_period)
      end
      totals.sort_by(&:group).reverse.map(&:user_id)

      get users_path,
          'performance[metric]' => 'group_sales',
          'performance[period]' => 'monthly',
          format:                  :json

      result = json_body['entities'].map { |e| e['properties']['id'] }

      expected = totals.sort_by(&:group).reverse.map(&:user_id)
      expect(result).to eq(expected)
    end

    it 'returns the users team sorted by quote count' do
      [ rand(5) + 1, rand(5) + 1, rand(5) + 1 ].map do |count|
        user = create(:user, sponsor: @user)
        create_list(:quote, count, user: user)
      end

      get users_path,
          'performance[metric]' => 'quote_count',
          'performance[period]' => 'lifetime',
          format: :json

      result = json_body['entities'].map { |e| e['properties']['quote_count'] }

      expect(result).to eq(result.sort.reverse)
    end

  end

  describe '#search' do
    context 'did not rank up yet' do
      it 'returns 401 unauthorized' do
        get user_path(1), format: :json

        expect(response.code).to eq('401')
      end
    end

    context 'ranked up' do
      before do
        allow_any_instance_of(AuthController).to receive(:verify_rank).and_return(true)
      end

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
  end

  describe '/:id' do
    context 'did not rank up yet' do
      it 'returns 401 unauthorized' do
        get user_path(1), format: :json

        expect(response.code).to eq('401')
      end
    end

    context 'ranked up' do
      before do
        allow_any_instance_of(AuthController).to receive(:verify_rank).and_return(true)
      end

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
  end

  describe '/u/users/:id/downline' do
    context 'did not rank up yet' do
      it 'returns 401 unauthorized' do
        get downline_user_path(1), format: :json

        expect(response.code).to eq('401')
      end
    end

    context 'ranked up' do
      before do
        allow_any_instance_of(AuthController).to receive(:verify_rank).and_return(true)
      end

      it 'returns the downline users' do
        child = create_list(:user, 3, sponsor: @user).first

        create_list(:user, 2, sponsor: child)

        get downline_user_path(@user), format: :json

        expect_200

        found_child = json_body['entities']
                      .find { |e| e['properties']['id'] == child.id }
        expect(found_child).to_not be_nil
      end
    end
  end

  describe '/u/users/:id/upline' do
    context 'did not rank up yet' do
      it 'returns 401 unauthorized' do
        get upline_user_path(1), format: :json

        expect(response.code).to eq('401')
      end
    end

    context 'ranked up' do
      before do
        allow_any_instance_of(AuthController).to receive(:verify_rank).and_return(true)
      end

      it 'returns the upline users' do
        grand_parent = create(:user, sponsor: @user, first_name: 'Pappy')
        parent = create(:user, sponsor: grand_parent, first_name: 'Parent')
        child = create(:user, sponsor: parent, first_name: 'Child')

        get upline_user_path(child), format: :json

        expect_200

        found_parent = json_body['entities'].find do |e|
          e['properties']['id'] == parent.id
        end
        found_grand_parent = json_body['entities'].find do |e|
          e['properties']['id'] == grand_parent.id
        end
        expect(found_parent).to_not be_nil
        expect(found_grand_parent).to_not be_nil
        expect(json_body['entities'].count).to eq(3)
      end
    end
  end

  describe '/u/users/:id/eligible_parents' do

    def user_exists?(id)
      json_body['entities'].any? { |e| e['properties']['id'] == id }
    end

    context 'did not rank up yet' do
      it 'returns 401 unauthorized' do
        get eligible_parents_user_path(1), format: :json

        expect(response.code).to eq('401')
      end
    end

    context 'ranked up' do
      before do
        allow_any_instance_of(AuthController).to receive(:verify_rank).and_return(true)
      end

      it 'returns the correct parents with the correct order' do
        mover = create(:user, sponsor: @user)
        ineligible = create(:user, sponsor: mover)
        parent1 = create(:user, sponsor: @user)
        parent2 = create(:user, sponsor: @user)
        child1 = create(:user, sponsor: parent1)
        child2 = create(:user, sponsor: parent2)
        grand_child = create(:user, sponsor: child1)

        get eligible_parents_user_path(mover), format: :json

        expect(user_exists?(ineligible.id)).to_not be
        [ parent1, parent2, child1, child2, grand_child ].each do |user|
          expect(user_exists?(user.id)).to be
        end
      end
    end
  end

  describe '/u/users/:id/move' do
    context 'did not rank up yet' do
      it 'returns 401 unauthorized' do
        post move_user_path(1, parent_id: 2), format: :json

        expect(response.code).to eq('401')
      end
    end

    context 'ranked up' do
      before do
        allow_any_instance_of(AuthController).to receive(:verify_rank).and_return(true)
      end

      it 'moves a user in the genealogy' do
        parent1 = create(:user, sponsor: @user)
        parent2 = create(:user, sponsor: @user)
        child = create(:user, sponsor: parent1)

        post move_user_path(parent1, parent_id: parent2.id), format: :json

        parent1.reload
        child.reload
        expect(parent1.parent_id).to eq(parent2.id)
        expect(child.ancestor?(parent2.id)).to be
      end

      it 'does not allow moving a user not in the downline' do
        @user.update_column(:roles, [])
        parent = create(:user, sponsor: @user)
        other_user = create(:user)

        post move_user_path(other_user, parent_id: parent.id), format: :json

        expect_alert_error
      end

      it 'does not allow moving to a user not in the downline' do
        other_user = create(:user)
        child = create(:user, sponsor: @user)

        post move_user_path(child, parent_id: other_user.id), format: :json

        expect_alert_error
      end
    end
  end

end

require 'spec_helper'

describe '/a/users' do

  before :each do
    login_user(auth: true)
  end

  describe '#index' do

    it 'returns level 1 users' do
      create_list(:user, 3)
      create_list(:user, 2, sponsor: @user)

      get admin_users_path, format: :json

      expect_200

      expect_classes('users', 'list')
      expect(json_body['entities'].size).to eq(User.at_level(1).count)
    end

    it 'returns the downline users' do
      child = create_list(:user, 3, sponsor: @user).first

      create_list(:user, 2, sponsor: child)

      get downline_admin_user_path(@user), format: :json

      expect_200

      found_child = json_body['entities'].find do |e|
        e['properties']['id'] == child.id
      end
      expect(found_child).to_not be_nil
      expect(found_child['properties']['downline_count']).to eq(2)
    end

    it 'requires the user to be an admin' do
      @user.roles = []
      @user.save!

      get admin_users_path, format: :json

      expect(response.status).to eq(401)
    end

    it 'filters by group' do
      group = create(:user_group)
      create_list(:user_user_group, 3, user_group: group)

      get admin_users_path, group: group.id, format: :json

      expect_entities_count(3)
    end

  end

  describe '/:id' do

    it 'returns the user detail' do
      get admin_user_path(@user), format: :json

      expect_entities 'user-orders'#, 'user-order_totals'
    end


    describe '/eligible_parents' do

      it 'returns the correct parents with the correct order' do
        mover = create(:user, sponsor: @user)
        create(:user, sponsor: @user)

        get eligible_parents_admin_user_path(mover), format: :json

        expect_entities_count(1)
      end

    end

  end



  describe '#update' do

    let(:params) do
      { address: '42 Sunshine Way',
        format:  :json }
    end

    it 'updates a user' do
      user = create(:user)

      patch admin_user_path(user), params

      expect_200
      expect(json_body['properties']['address']).to eq(params[:address])
    end

  end
end

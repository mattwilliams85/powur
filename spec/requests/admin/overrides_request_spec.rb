require 'spec_helper'

describe '/a' do

  before do
    DatabaseCleaner.clean
    login_user
  end

  describe '/overrides' do
    describe 'GET' do
      it 'does not include a create action' do
        get overrides_path, format: :json

        expect(json_body['actions']).to be_nil
      end
    end

    describe 'PATCH' do
      it 'udpates the start and end date of an override' do
        override = create(:override)
        start_date = (Date.current - 1.month).to_s
        end_date = (Date.current + 1.month).to_s
        patch override_path(override),
              start_date: start_date,
              end_date:   end_date,
              format:     :json

        expect_entities_count(1)
        result = json_body['entities'][0]
        expect(result['properties']['start_date'])
          .to eq(start_date)
        expect(result['properties']['end_date'])
          .to eq(end_date)
      end
    end

    describe 'DELETE' do
      it 'deletes an override' do
        override = create(:override)
        delete override_path(override), format: :json

        expect_entities_count(0)
      end
    end
  end

  describe '/users/:admin_user_id/overrides' do
    before :each do
      @user = create(:user)
    end

    describe 'GET' do
      it 'includes a create action' do
        get admin_user_overrides_path(@user), format: :json

        expect_actions('create')
      end

      it 'returns a list of overrides for a user' do
        create_list(:override, 3, user: @user)

        get admin_user_overrides_path(@user), format: :json

        expect_entities_count(3)
      end
    end
  end
end

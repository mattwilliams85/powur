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
        pay_period = create(:monthly_pay_period, at: 3.months.ago)
        override = create(:override)
        # end_date = (Date.current + 1.month).to_s
        patch override_path(override),
              pay_period_id: pay_period.id,
              format:        :json

        expect_entities_count(1)
        result = json_body['entities'][0]
        expect(result['properties']['start_date'])
          .to eq(pay_period.start_date.to_s)
        expect(result['properties']['end_date'])
          .to eq(pay_period.end_date.to_s)
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

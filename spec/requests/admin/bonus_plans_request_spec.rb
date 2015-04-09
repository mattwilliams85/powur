require 'spec_helper'

describe '/a/bonus_plans' do

  before do
    login_user
  end

  let(:start_year) { DateTime.current.year }
  let(:start_month) { DateTime.current.month }

  describe 'GET /' do

    it 'returns a list of bonus plans' do
      create_list(:bonus_plan, 3)

      get bonus_plans_path, format: :json

      expect_classes 'bonus_plans'
      expect_entities_count(3)
    end

  end

  describe 'GET /:id' do

    it 'returns an individual bonus plan' do
      bonus_plan = create(:bonus_plan,
                          start_year:  start_year,
                          start_month: start_month)

      get bonus_plan_path(bonus_plan), format: :json

      expect_classes 'bonus_plan'
      expect_actions 'update'
      expect_entities 'bonus-plan-bonuses'
      expect_props active: true
    end

  end

  describe 'POST /' do

    it 'creates a bonus plan' do
      post bonus_plans_path, name: 'foo', format: :json

      expect_classes 'bonus_plan'
    end

    it 'does not allow two plans with the same start time' do
      create(:bonus_plan, start_year: start_year, start_month: start_month)
      post bonus_plans_path,
           name:        'foo',
           start_year:  start_year,
           start_month: start_month,
           format:      :json

      expect_alert_error
    end

  end

  describe 'PATCH /:id' do

    it 'updates an individual bonus plan' do
      bonus_plan = create(:bonus_plan)

      patch bonus_plan_path(bonus_plan), format: :json,
            start_year: @start_year, start_month: @start_month

      expect_classes 'bonus_plan'
      expect_props start_year: @start_year, start_month: @start_month
    end

    it 'does not allow two plans with the same start time' do
      create(:bonus_plan, start_year: start_year, start_month: start_month)
      bonus_plan = create(:bonus_plan)

      patch bonus_plan_path(bonus_plan), format: :json,
        start_year: start_year, start_month: start_month

      expect_alert_error
    end

  end

end

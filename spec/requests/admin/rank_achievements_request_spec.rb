require 'spec_helper'

describe 'rank achievements', type: :request do

  before :each do
    login_user
    create_list(:rank, 5)
  end

  describe '/a/pay_periods/:id/rank_achievements' do

    it 'pages a list for the pay period' do
      at = DateTime.current - 1.month
      pay_period = WeeklyPayPeriod.find_or_create_by_date(at)
      achievement = create(:rank_achievement,
                           rank_id:    2,
                           pay_period: pay_period)
      create_list(:rank_achievement, 3, rank_id: 2, pay_period: pay_period)
      create(:rank_achievement,
             rank_id:    3,
             user:       achievement.user,
             pay_period: pay_period)

      get pay_period_rank_achievements_path(pay_period),
          format: :json, limit: 3
      expect_entities_count(3)

      get pay_period_rank_achievements_path(pay_period),
          format: :json, limit: 2, page: 2
      expect_entities_count(2)
    end

    it 'sorts a list by user name' do
      achievement = create(:rank_achievement, rank_id: 2)
      list = create_list(:rank_achievement, 3,
                         rank_id:    2,
                         pay_period: achievement.pay_period)
      list << achievement

      get pay_period_rank_achievements_path(achievement.pay_period),
          format: :json, sort: :user

      expected = list.sort_by do |a|
        [ a.user.last_name, a.user.first_name ]
      end
      expected = expected.map { |a| a.user.full_name }
      result = json_body['entities'].map { |a| a['properties']['user'] }

      expect(result).to eq(expected)
    end

  end

  describe '/a/users/:id/rank_achievements' do

    before :each do
      @achiever = create(:user)
      create(:rank_achievement, rank_id: 2, pay_period: nil, user: @achiever)
      @pp_achievement = create(:rank_achievement, rank_id: 3, user: @achiever)
    end

    it 'renders a list of lifetime ranks with no pay period filter' do
      get admin_user_rank_achievements_path(@achiever), format: :json

      expect_entities_count(1)
      result = json_body['entities'].first['properties']['rank_id']
      expect(result).to eq(2)
    end

    it 'fitlers by pay period' do
      get admin_user_rank_achievements_path(@achiever),
          pay_period: @pp_achievement.pay_period_id,
          format:     :json

      expect_entities_count(1)
      result = json_body['entities'].first['properties']['rank_id']
      expect(result).to eq(3)
    end
  end
end

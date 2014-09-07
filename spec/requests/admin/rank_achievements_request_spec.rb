require 'spec_helper'

describe 'order totals', type: :request do

  before :each do
    login_user
    create_list(:rank, 5)
  end

  describe '/a/pay_periods/:id/rank_achievements' do

    it 'pages a list for the pay period' do
      achievement = create(:rank_achievement, rank_id: 2)
      create_list(:rank_achievement, 3, rank_id: 2, pay_period: achievement.pay_period)
      create(:rank_achievement, 
        rank_id:    3, 
        user:       achievement.user, 
        pay_period: achievement.pay_period)

      get pay_period_rank_achievements_path(achievement.pay_period), 
        format: :json, limit: 3
      expect_entities_count(3)

      get pay_period_rank_achievements_path(achievement.pay_period), 
        format: :json, limit: 2, page: 2
      expect_entities_count(2)
    end

    it 'sorts a list by user name' do
      achievement = create(:rank_achievement, rank_id: 2)
      list = create_list(:rank_achievement, 3, rank_id: 2, pay_period: achievement.pay_period)
      list << achievement

      get pay_period_rank_achievements_path(achievement.pay_period), 
        format: :json, sort: :user

      expected = list.sort_by { |a| [ a.user.last_name, a.user.first_name ] }.
        map { |a| a.user.full_name }
      # binding.pry

    end

  end

  describe '/a/users/:id/order_totals' do

    it 'returns a list of order totals for the user' do
      achievement = create(:rank_achievement, rank_id: 2)
      create(:rank_achievement, rank_id: 3, pay_period: achievement.pay_period, user: achievement.user)

      get admin_user_rank_achievements_path(achievement.user), format: :json
      expect_entities_count(2)
    end
  end

end

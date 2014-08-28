require 'spec_helper'

describe 'order totals', type: :request do

  before :each do
    login_user
    create_list(:rank, 5)
  end

  describe '/a/pay_periods/:id/rank_achievements' do

    it 'returns a list of rank achievements for the pay period' do
      achievement = create(:rank_achievement, rank_id: 2)
      create(:rank_achievement, rank_id: 2, pay_period: achievement.pay_period)
      create(:rank_achievement, 
        rank_id:    3, 
        user:       achievement.user, 
        pay_period: achievement.pay_period)

      get pay_period_rank_achievements_path(achievement.pay_period), format: :json
      expect_entities_count(3)
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

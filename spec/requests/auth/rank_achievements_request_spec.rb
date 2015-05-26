# require 'spec_helper'

# describe '/u/users/:id/rank_achievements' do

#   before :each do
#     login_user
#     create_list(:rank, 5)
#   end

#   it 'returns a list of rank achievements for the user' do
#     achievement = create(:rank_achievement, rank_id: 2)
#     create(:rank_achievement,
#            rank_id:    3,
#            pay_period: achievement.pay_period,
#            user:       achievement.user)

#     get user_rank_achievements_path(achievement.user), format: :json
#     expect_entities_count(2)
#   end
# end

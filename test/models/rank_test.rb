require 'test_helper'
 
class RankTest < ActiveSupport::TestCase

  def test_rank_user
    user_id = users(:advocate).id
    Rank.rank_user(user_id)

    result = UserRank.where(user_id: user_id, rank_id: 1).exists?
    result.must_equal true
  end
end

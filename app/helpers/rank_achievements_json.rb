module RankAchievementsJson
  class RankAchievementsViewDecorator < JsonDecorator
    def list_init(partial_path = 'item')
      klass :rank_achievements, :list

      list_entities(partial_path)
    end

    def item_init(rel = nil)
      klass :rank_achievement

      entity_rel(rel) if rel
    end

    def list_item_properties(rank_achievement = @item)
      json.properties do
        json.call(rank_achievement, :pay_period_id, :user_id,
                  :path, :rank_id, :achieved_at)
        json.lifetime rank_achievement.lifetime?
        json.user rank_achievement.user.full_name
      end
    end

    # def properties(rank_achievement = @item)
    #   json.properties do
    #     json.call(rank_achievement, :pay_period_id, :user_id,
    #               :path, :rank_id, :achieved_at)
    #     json.lifetime rank_achievement.lifetime?
    #     json.user rank_achievement.user.full_name
    #     json.rank rank_achievement.rank.title
    #   end
    # end

    def list_entities(partial_path, list = @list)
      json.entities list, partial: partial_path, as: :rank_achievement
    end

    def item(path, rank_achievement)
      klass :rank_achievement

      properties(rank_achievement)

      self_link path
    end
  end

  def rank_achievements_json
    @rank_achievement_json ||= RankAchievementsViewDecorator.new(
      self,
      @rank_achievements,
      @rank_achievement)
  end
end

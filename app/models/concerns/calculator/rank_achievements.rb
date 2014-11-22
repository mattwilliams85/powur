module Calculator
  module RankAchievements
    extend ActiveSupport::Concern

    def process_rank_achievements!(order, totals = nil)
      totals ||= find_order_total(order.user_id, order.product_id)

      process_lifetime_rank_achievements(order, totals)
      process_pay_period_rank_achievements(order, totals)

      order.user.parent_ids.each do |user_id|
        parent = find_upline_user(user_id)
        parent_totals = find_order_total(user_id, order.product_id)

        process_lifetime_rank_achievements(order, parent_totals, parent)
        process_pay_period_rank_achievements(order, parent_totals, parent)
      end
    end

    def process_lifetime_rank_achievements(order, totals, user = nil)
      user ||= order.user

      qualification_paths.each do |path|
        start = highest_rank(user.id, path, lifetime_rank_achievements)

        ranks[start..-1].each do |rank|
          break unless rank.lifetime_path?(path) &&
                       rank.qualified_path?(path, totals)

          lifetime_rank_achieved!(user, rank, path, order)
        end
      end
    end

    def process_pay_period_rank_achievements(order, totals, user = nil)
      user ||= order.user

      qualification_paths.each do |path|
        start = highest_rank(user.id, path,
                             lifetime_rank_achievements,
                             rank_achievements)

        ranks[start..-1].each do |rank|
          break unless rank_has_path?(rank, path) &&
                       rank.qualified_path?(path, totals)

          rank_achieved!(user, rank, path, order)
        end
      end
    end

    private

    def highest_rank(user_id, path, *lists)
      lists.inject([ 1 ]) do |ranks, list|
        ranks << list.select do |a|
          a.user_id == user_id && a.rank_path_id == path.id
        end.map(&:rank_id).max
      end.compact.max
    end

    def rank_achieved!(user, rank, path, order, builder = rank_achievements)
      attrs = {
        achieved_at: order.order_date,
        user_id:     user.id,
        rank_id:     rank.id,
        rank_path:   path }
      achievement = builder.create!(attrs)
      if user.lifetime_rank < achievement.rank_id
        user.update_column(:lifetime_rank, achievement.rank_id)
      end
      achievement
    end

    def lifetime_rank_achieved!(user, rank, path, order)
      achievement = rank_achieved!(user, rank, path, order, RankAchievement)

      lifetime_rank_achievements << achievement
      return unless user.organic_rank < achievement.rank_id

      user.update_columns(
        organic_rank: achievement.rank_id,
        rank_path_id: path.id)
    end
  end
end

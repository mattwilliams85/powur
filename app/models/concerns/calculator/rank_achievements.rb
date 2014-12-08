module Calculator
  module RankAchievements
    extend ActiveSupport::Concern

    def process_rank_achievements!(order, totals = nil)
      return unless default_rank_path
      totals ||= find_order_total(order.user_id, order.product_id)

      process_user_rank_achievements(order, totals)

      order.user.parent_ids.each do |user_id|
        parent = find_upline_user(user_id)
        parent_totals = find_order_total(user_id, order.product_id)

        process_user_rank_achievements(order, parent_totals, parent)
      end
    end

    def process_user_rank_achievements(order, totals, user = nil)
      process_rank_path_changes(order, totals, user)
      process_lifetime_rank_achievements(order, totals, user)
      process_pay_period_rank_achievements(order, totals, user)
    end

    def process_rank_path_changes(order, totals, user = nil)
      user ||= order.user

      unless user.rank_path
        user.update_column(:rank_path_id, default_rank_path.id)
      end

      paths = rank_paths.select do |path|
        path.precedence > user.rank_path.precedence
      end

      first_rank = ranks.first
      paths.each do |path|
        next unless first_rank.lifetime_path?(path.id) &&
                    first_rank.qualified_path?(path.id, totals)

        lifetime_rank_achieved!(user, first_rank, path, order)
      end
    end

    def process_lifetime_rank_achievements(order, totals, user = nil)
      user ||= order.user

      path = user.rank_path
      start = highest_rank(user.id, path.id, lifetime_rank_achievements)
      ranks[start..-1].each do |rank|
        break unless rank.lifetime_path?(path.id) &&
                     rank.qualified_path?(path.id, totals)

        lifetime_rank_achieved!(user, rank, path, order)
      end
    end

    def process_pay_period_rank_achievements(order, totals, user = nil)
      user ||= order.user

      path = user.rank_path
      start = highest_rank(user.id, path.id,
                           lifetime_rank_achievements,
                           rank_achievements)
      ranks[start..-1].each do |rank|
        break unless rank_has_path?(rank, path.id) &&
                     rank.qualified_path?(path.id, totals)

        rank_achieved!(user, rank, path, order)
      end
    end

    private

    def rank_paths
      @rank_paths ||= RankPath.all.order(:precedence)
    end

    def default_rank_path
      @default_rank_path ||= rank_paths.find(&:default?)
    end

    def highest_rank(user_id, path_id, *lists)
      lists.inject([ 1 ]) do |ranks, list|
        ranks << list.select do |a|
          a.user_id == user_id && a.rank_path_id == path_id
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

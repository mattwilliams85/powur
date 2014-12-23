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

    # rubocop:disable Metrics/AbcSize
    def process_rank_path_changes(order, totals, user = nil)
      user ||= order.user

      unless user.rank_path
        user.update_column(:rank_path_id, default_rank_path.id)
      end

      new_user_paths(user).each do |path|
        next unless first_rank.lifetime_path?(path.id) &&
                    first_rank.qualified_path?(path.id, totals)

        lifetime_rank_achieved!(user, first_rank, path, order)
      end
    end

    def process_lifetime_rank_achievements(order, totals, user = nil)
      user ||= order.user

      path = user.rank_path
      highest = highest_achievement(user.id,
                                    lifetime_rank_achievements)
      if highest
        update_user_lifetime_rank(user, highest)
        start = highest.rank_id
      else
        start = 1
      end

      ranks[start..-1].each do |rank|
        break unless rank.lifetime_path?(path.id) &&
                     rank.qualified_path?(path.id, totals)

        lifetime_rank_achieved!(user, rank, path, order)
      end
    end

    def process_pay_period_rank_achievements(order, totals, user = nil)
      user ||= order.user

      path = user.rank_path
      highest = highest_achievement(
        user.id,
        lifetime_rank_achievements + rank_achievements)
      start = highest ? highest.rank_id  : 1
      ranks[start..-1].each do |rank|
        break unless rank_has_path?(rank, path.id) &&
                     rank.qualified_path?(path.id, totals)

        rank_achieved!(user, rank, path, order)
      end
    end

    private

    def new_user_paths(user)
      rank_paths.select { |path| path.precedence > user.rank_path.precedence }
    end

    def lifetime_rank_achievements
      @lifetime_rank_achievements ||=
        RankAchievement.lifetime.where(user_id: all_user_ids).entries
    end

    def first_rank
      ranks.first
    end

    def rank_paths
      @rank_paths ||= RankPath.all.order(:precedence)
    end

    def rank_path(id)
      rank_paths.find { |path| path.id == id }
    end

    def default_rank_path
      @default_rank_path ||= rank_paths.find(&:default?)
    end

    def highest_achievement(user_id, list)
      achievements = list.select { |a| a.user_id == user_id }
      achievements.sort_by do |a|
        [ rank_path(a.rank_path_id).precedence, a.rank_id ]
      end.last
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

      update_user_lifetime_rank(user, achievement)
    end

    def update_user_lifetime_rank(user, achievement)
      return if user.rank_path_id == achievement.rank_path_id &&
                user.organic_rank == achievement.rank_id
      user.update_columns(
        organic_rank: achievement.rank_id,
        rank_path_id: achievement.rank_path_id)
    end
  end
end

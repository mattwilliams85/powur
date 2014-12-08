namespace :sunstand do
  namespace :reset do
    task user_ranks: :environment do
      RankAchievement.delete_all
      User.update_all(organic_rank: 1, lifetime_rank: 1, rank_path_id: 1)
    end
  end
end

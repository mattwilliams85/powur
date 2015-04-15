namespace :powur do
  namespace :reset do
    task user_ranks: :environment do
      RankAchievement.delete_all
      User.update_all(organic_rank: nil, lifetime_rank: nil, rank_path_id: nil)
    end
  end
end

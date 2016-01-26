namespace :powur do
  namespace :job do
    task refresh_lead_totals_and_ranks: :environment do
      puts 'Refreshing lead totals for current month'
      UserTotals.calculate_latest
      puts 'Ranking users for current month'
      Rank.rank_users(MonthlyPayPeriod.current_id)
    end
  end
end

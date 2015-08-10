namespace :powur do
  namespace :job do
    task refresh_lead_totals: :environment do
      puts 'Refreshing lead totals for current month'
      LeadTotals.calculate_latest
      puts 'Ranking users for current month'
      Rank.rank_users(MonthlyPayPeriod.current_id)
    end
  end
end

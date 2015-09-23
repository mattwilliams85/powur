namespace :powur do
  namespace :metrics do
    task partners: :environment do
      results = ProductReceipt
        .select("date_trunc('week', purchased_at) AS week, count(*) AS count")
        .where("amount > 0 AND purchased_at > now() - interval '12 months'")
        .group('1')
        .order('1')

      CSV.open('/tmp/powur_metrics_partners.csv', 'w') do |csv|
        csv << %w(week_start week_end purchases_count)
        results.each { |i| csv << [i.week.to_date.to_s(:long),
                                   (i.week + 6.days).to_date.to_s(:long),
                                   i.count] }
      end
    end
  end
end

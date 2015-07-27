namespace :powur do
  def quotes_counts(from)
    User.select('users.id, COUNT(quotes.id) as quotes_count')
      .joins(:quotes)
      .where(['quotes.submitted_at > ?', from.to_s(:db)])
      .group('users.id')
  end

  def advocates_counts(from)
    User.advocates
      .where(['users.created_at > ?', from.to_s(:db)])
      .select('users.sponsor_id AS id, COUNT(users.id) AS advocates_count')
      .group('users.sponsor_id')
  end

  def partners_counts(from)
    User.partners
      .where(['users.created_at > ?', from.to_s(:db)])
      .select('users.sponsor_id AS id, COUNT(users.id) AS partners_count')
      .group('users.sponsor_id')
  end

  def row(id, stats)
    user = User.find_by(id: id)
    sponsor = user.try(:sponsor)
    [
      user.try(:id),
      user.try(:full_name),
      sponsor.try(:id),
      sponsor.try(:full_name),
      stats[:quotes_count],
      stats[:advocates_count],
      stats[:partners_count]
    ]
  end

  task stats: :environment do
    stats_data = {}
    from = Time.zone.now.beginning_of_month

    (quotes_counts(from) +
    advocates_counts(from) +
    partners_counts(from)).each do |i|
      stats_data[i.id] ||= {}
      stats_data[i.id][:quotes_count] ||= i.try(:quotes_count)
      stats_data[i.id][:advocates_count] ||= i.try(:advocates_count)
      stats_data[i.id][:partners_count] ||= i.try(:partners_count)
    end

    CSV.open('/tmp/user_stats.csv', 'w') do |csv|
      csv << %w(user_id user_name sponsor_id sponsor_name
                submitted_quotes created_advocates created_partners)
      stats_data.each { |k, v| csv << row(k, v) }
    end
  end





  # def in_territory(zip)
  #   # sleep 1
  #   response = Net::HTTP.get('api.solarcity.com', '/solarbid/api/warehouses/zip/' + zip)
  #   JSON.parse(response)['IsInTerritory']
  # end
  #
  # task stats: :environment do
  #   results = {
  #     'no_zip' =>   {'count' => 0, 'q_total' => 0, 'q_submitted' => 0, 'q_not_submitted' => 0, 'q_won' => 0, 'q_lost' => 0, 'q_lost_out_of_service' => 0},
  #     'in_area' =>  {'count' => 0, 'q_total' => 0, 'q_submitted' => 0, 'q_not_submitted' => 0, 'q_won' => 0, 'q_lost' => 0, 'q_lost_out_of_service' => 0},
  #     'out_area' => {'count' => 0, 'q_total' => 0, 'q_submitted' => 0, 'q_not_submitted' => 0, 'q_won' => 0, 'q_lost' => 0, 'q_lost_out_of_service' => 0}
  #   }
  #
  #   User.all.each do |u|
  #     if u.zip
  #       if in_territory(u.zip)
  #         key = 'in_area'
  #         puts key
  #       else
  #         key = 'out_area'
  #         puts key
  #       end
  #     else
  #       key = 'no_zip'
  #       puts key
  #     end
  #
  #     results[key]['count'] += 1
  #     results[key]['q_total'] += u.quotes.count
  #     results[key]['q_submitted'] += u.quotes.submitted.count
  #     results[key]['q_not_submitted'] += u.quotes.not_submitted.count
  #     results[key]['q_won'] += u.quotes.closed_won.count
  #     results[key]['q_lost'] += u.quotes.lost.count
  #     results[key]['q_lost_out_of_service'] += LeadUpdate.select("DISTINCT ON (quote_id) *").where(quote_id: u.quote_ids, status: 'out_of_service_area').length
  #   end
  #
  #   puts 'Result:'
  #   puts results
  # end
end

namespace :powur do
  namespace :report do
    def with_csv_iterator(file_name, headers, iterator)
      CSV.open("/tmp/#{file_name}.csv", 'w') do |csv|
        csv << headers
        iterator.each { |item| csv << yield(item) }
      end
    end

    NOV_DEC_2015_HEADERS = %w(id name email qualified_leads
                              sponsored_partners points)
    FROM = Date.parse('2015-11-01')
    task nov_dec_2015: :environment do
      leads = Lead.converted(from: FROM)
        .references(:user).includes(:user)

      rows = leads.each_with_object({}) do |lead, users|
        if users[lead.user_id].nil?
          users[lead.user_id] = { user: lead.user }
          users[lead.user_id][:leads] = 1
        else
          users[lead.user_id][:leads] += 1
        end
      end

      sponsees = ProductReceipt
        .where(product_id: 3)
        .where('purchased_at >= ?', FROM)
        .references(:user).includes(:user).map(&:user)

      sponsees.each do |user|
        if rows[user.sponsor_id].nil?
          rows[user.sponsor_id] = { user: user.sponsor }
          rows[user.sponsor_id][:partners] = 1
        else
          rows[user.sponsor_id][:partners] = 0
          rows[user.sponsor_id][:partners] += 1
        end
      end

      rows = rows.values.sort_by do |row|
        row[:leads] ||= 0
        row[:partners] ||= 0
        -(row[:points] = (row[:leads] * 2) + row[:partners])
      end

      with_csv_iterator('nov_dec_2015_contest',
                        NOV_DEC_2015_HEADERS,
                        rows) do |row|

        user = row[:user]
        [ user.id, user.full_name, user.email, row[:leads],
          row[:partners], row[:points] ]
      end
    end
  end
end
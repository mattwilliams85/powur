namespace :powur do
  namespace :report do
    #
    # Generates 2 csv files:
    # /tmp/nov_dec_2015_leads.csv (Closed won/lost for Nov/Dec pay periods)
    # /tmp/nov_dec_2015_certs.csv (Cert purchases for Nov/Dec)
    #
    task nov_dec_2015: :environment do
      leads = Lead
        .includes(:user).references(:user)
        .where('sales_status = ? OR sales_status = ?',
               Lead.sales_statuses[:closed_won],
               Lead.sales_statuses[:closed_lost])

      CSV.open('/tmp/nov_dec_2015_leads.csv', 'w') do |csv|
        csv << %w(lead_id user_id name email closed_won_at)
        %w(2015-11 2015-12).each do |pp|
          leads.submitted(pay_period_id: pp).each do |lead|
            csv << [ lead.id,
                     lead.user_id,
                     lead.user.full_name,
                     lead.user.email,
                     lead.closed_won_at.try(:to_s, :long) ]
          end
        end
      end

      purchases = ProductReceipt
        .where(product_id: 3)
        .where('purchased_at >= ?', Date.parse('2015-11-01'))
        .where('purchased_at <= ?', Date.parse('2015-12-31'))
        .order(purchased_at: :asc)
        .references(:user).includes(:user)

      CSV.open('/tmp/nov_dec_2015_certs.csv', 'w') do |csv|
        csv << %w(user_id name email date_of_purchase sponsor_id sponsor_name)
        purchases.each do |purchase|
          csv << [ purchase.user_id,
                   purchase.user.full_name,
                   purchase.user.email,
                   purchase.purchased_at.try(:to_s, :long),
                   purchase.user.sponsor_id,
                   purchase.user.sponsor.full_name ]
        end
      end
    end
  end
end

namespace :powur do
  namespace :report do
    DUPE_LEAD_HEADERS = %w(external_id sc_id powur_rep_id powur_rep_name
                           full_name email phone address submitted_at)
    task duplicate_leads: :environment do
      CSV.open('/tmp/powur_report_duplicate_leads.csv', 'w+') do |csv|
        csv << DUPE_LEAD_HEADERS
        Lead.includes(:customer).references(:customer).duplicate.each do |lead|
          customer = lead.customer
          csv << [ "production.powur.com:#{lead.id}",
                   lead.provider_uid,
                   lead.user_id,
                   lead.user.full_name,
                   customer.full_name,
                   customer.email,
                   customer.phone,
                   customer.full_address,
                   lead.submitted_at.to_s(:long) ]
        end
      end
    end
  end
end

namespace :powur do
  namespace :report do
    def with_csv_iterator(file_name, headers, iterator)
      CSV.open("/tmp/#{file_name}.csv", 'w') do |csv|
        csv << headers
        iterator.each { |item| csv << yield(item) }
      end
    end

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

    SUBMITTED_LEAD_HEADERS = %w(id, name, email, phone, address, status)

    task submitted_leads: :environment do
      records = Lead
        .includes(:customer).references(:customer)
        .includes(:user).references(:user)
        .submitted

      with_csv_iterator(
        'submitted_leads', SUBMITTED_LEAD_HEADERS, records) do |lead|
        customer = lead.customer
        [ lead.id,
          customer.full_name,
          customer.email,
          customer.phone,
          customer.full_address,
          lead.sales_status ]
      end
    end
  end
end

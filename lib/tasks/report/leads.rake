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

    RELEVANT_STATUSES = [ :submitted, :closed_won, :contracted, :installed ]
    MONTHLY_LEAD_HEADERS = [
      :id, :rep, :customer, :submitted,
      :closed_won, :contracted, :installed ]
    task :monthly_leads, [ :pay_period_id ] => :environment do |_t, args|
      lead_ids = RELEVANT_STATUSES.inject([]) do |ids, status|
        status_ids = Lead
          .send(status, pay_period_id: args.pay_period_id).pluck(:id)
        ids.push(*status_ids)
      end.uniq

      file_name = "#{args.pay_period_id}_leads"
      leads = Lead
        .where(id: lead_ids)
        .includes(:customer).references(:customer)
        .includes(:user).references(:user)
      
      with_csv_iterator(file_name, MONTHLY_LEAD_HEADERS, leads) do |lead|
        [ lead.id,
          lead.user.full_name,
          lead.customer.full_name,
          lead.submitted_at,
          lead.closed_won_at,
          lead.contracted_at,
          lead.installed_at ]
      end
    end

    task missing_submitted: :environment do
      data = CSV.read('tmp/sc_all_leads.csv')[1..-1]
      missing = data.each_with_object([]) do |record, ids|
        next unless record[0]
        lead_id = record[0].split(':').last.to_i
        ids << lead_id unless Lead.submitted.where(id: lead_id).exists?
      end
    end
  end
end

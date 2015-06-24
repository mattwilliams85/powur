namespace :powur do
  namespace :report do
    HEADERS = %w(
      advocate_id email first_name last_name lead_id status lead_status
      opportunity_stage submitted_date consultation_date contract_date
      installation_date updated_at)

    def query
      LeadUpdate.joins(:quote).includes(:quote)
        .order('quotes.user_id asc, quotes.id asc')
        .order(:updated_at)
    end

    def row(lead_update)
      quote = lead_update.quote
      user = quote.user
      [ user.id, user.email, user.first_name, user.last_name,
        quote.id, lead_update.status, lead_update.lead_status,
        lead_update.opportunity_stage, quote.submitted_at,
        lead_update.consultation, lead_update.contract,
        lead_update.installation, lead_update.updated_at ]
    end

    task lead_updates: :environment do
      CSV.open('/tmp/lead_updates.csv', 'w') do |csv|
        csv << HEADERS
        query.each { |lead_update| csv << row(lead_update) }
      end
    end
  end
end

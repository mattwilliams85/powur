namespace :powur do
  namespace :seed do

    def with_csv(file)
      path = Rails.root.join('db', 'seed', "#{file}.csv")
      csv = CSV.read(path)
      headers = csv.shift
      csv.each do |row|
        yield(row, headers) if block_given?
      end
    end

    task leads: :environment do
      with_csv('leads') do |row, _headers|
        quote_id = row[11].to_i
        if quote_id == 0
          puts "Identifier not found for lead, skipping..."
          next
        end

        attrs = {
          first_name: row[2],
          last_name:  row[3],
          phone:      row[4],
          email:      row[5].strip,
          address:    row[6] && row[6].strip,
          city:       row[7] && row[7].strip,
          state:      row[8] && row[8].strip,
          zip:        row[9] && row[9].strip }
        customer = Customer.find_by(email: attrs[:email])
        if customer
          customer.update_attributes(attrs)
          puts "Updated customer #{customer.id} : #{customer.full_name}"
        else
          customer = Customer.create!(attrs)
          puts "Created customer #{customer.id} : #{customer.full_name}"
        end
        attrs = {
          id:         row[11].to_i,
          product_id: 1,
          user_id:    row[1].to_i,
          customer:   customer,
          created_at: DateTime.strptime(row[0], '%m/%d/%Y %H:%M:%S') }
        attrs[:data] = { average_bill: row[10].strip } if row[10].presence

        quote = Quote.find_by(id: attrs[:id])
        if quote
          quote.update_attributes!(attrs) unless quote.submitted?
          puts "Updated lead #{quote.id}"
        else
          quote = Quote.create!(attrs)
          puts "Created lead #{quote.id}"
        end
      end
    end

    def initialize_lead_submission
      VCR.configure do |c|
        c.cassette_library_dir = 'spec/cassettes'
        c.hook_into :webmock
      end
      ENV['DATA_API_ENV'] = 'production'
      ENV['SOLAR_CITY_LEAD_URL'] = 'https://sctypowur.cloudhub.io/powur'
    end

    def submit_lead(lead, only_previous = true)
      if only_previous
        path = Rails.root.join('spec', 'cassettes', 'leads', "#{lead.id}.yml")
        if !File.exists?(path)
          puts "Lead : #{lead.id} not previously submitted, skipping"
          return
        end
      end

      VCR.use_cassette("leads/#{lead.id}") do
        lead.submit!(true)
      end
      puts "Submitted quote: #{lead.id} : #{lead.provider_uid}"
    end

    def submit_leads(only_previous)
      initialize_lead_submission

      quotes = Quote.not_submitted
      quotes.each do |quote|
        submit_lead(quote, only_previous)
      end
    end

    task submitted_leads: :environment do
      submit_leads(true)
    end

    task submit_leads: :environment do
      submit_leads(false)
    end
  end
end

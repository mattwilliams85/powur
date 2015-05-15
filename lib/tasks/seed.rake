namespace :powur do
  namespace :seed do

    def with_csv(file)
      path = Rails.root.join('db', 'seed', "#{file}.csv")
      csv = CSV.read(path)
      csv.shift
      csv.each do |row|
        yield(row) if block_given?
      end
    end

    def move_user(user, placement_id)
      parent = User.find(placement_id)
      User.move_user(user, parent)
      puts "Moved user #{user.id} : #{user.full_name} to new parent #{placement_id}"
    end

    PASSWORD = 'solarpower42'
    task advocates: :environment do
      with_csv('advocates') do |row|
        attrs = {
          id:         row[0].to_i,
          first_name: row[3].strip,
          last_name:  row[4].strip,
          phone:      row[5] && row[5].strip,
          email:      row[6].strip,
          address:    row[7] && row[7].strip,
          city:       row[8] && row[8].strip,
          state:      row[9] && row[9].strip,
          zip:        row[10] && row[10].strip }
        attrs[:sponsor_id] = row[1].to_i if row[1]

        user = User.find_by(id: attrs[:id])
        if user
          user.update_attributes(attrs)
          puts "Updated user #{user.id} : #{user.full_name}"
          move_user(user, row[2].to_i) if row[2] && row[2] != row[1]
          next
        end

        attrs.merge!(
          password:              PASSWORD,
          password_confirmation: PASSWORD,
          tos:                   true)

        user = User.create!(attrs)
        puts "Created user #{user.id} : #{user.full_name}"
        move_user(user, row[2].to_i) if row[2] && row[2] != row[1]
      end
    end

    task leads: :environment do
      with_csv('leads') do |row|
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

    def configure_vcr
      VCR.configure do |c|
        c.cassette_library_dir = 'spec/cassettes'
        c.hook_into :webmock
      end
    end


    task submit_leads: :environment do
      configure_vcr
      ENV['DATA_API_ENV'] = 'production'
      ENV['SOLAR_CITY_LEAD_URL'] = 'https://sctypowur.cloudhub.io/powur'

      quotes = Quote.not_submitted
      quotes.each do |quote|
        VCR.use_cassette("leads/#{quote.id}") do
          quote.submit!
        end
        puts "Submitted quote: #{quote.id} : #{quote.provider_uid}"
      end
    end
  end
end
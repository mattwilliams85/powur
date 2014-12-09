namespace :sunstand do
  namespace :simulate do

    def generate_user(attrs = {})
      attrs = {
        password:      'solarpower',
        email:         Faker::Internet.email,
        first_name:    Faker::Name.first_name,
        last_name:     Faker::Name.last_name,
        phone:         Faker::PhoneNumber.phone_number,
        zip:           Faker::Address.zip,
        address:       Faker::Address.street_address,
        city:          Faker::Address.city,
        state:         Faker::Address.state_abbr,
        lifetime_rank: 1,
        created_at:    2.years.ago }.merge(attrs)

      User.create!(attrs)
    end

    def generate_downline(user, levels, per_user, max_users)
      return max_users if max_users.zero? || levels.zero?
      per_user = max_users if max_users < per_user

      children = 1.upto(rand(0..per_user)).map do |_i|
        generate_user(sponsor: user)
      end
      max_users -= children.count

      puts "\tgenerated #{children.count} children: #{max_users} max left..."
      children.each do |child|
        max_users = generate_downline(
          child,
          levels - 1,
          per_user - (per_user / levels),
          max_users)
        break if max_users.zero?
      end

      max_users
    end

    desc 'Simulate users'
    task :users, [ :total, :per_user, :levels ] => :environment do |_t, args|
      args.with_defaults(total: 600, per_user: 20, levels: 4)

      users = User.all.to_a

      Rank.find_or_create_by_id(1)

      if users.empty?
        puts 'no users found generating 5 root admin users'
        users = 1.upto(5).map { |_i| generate_user(roles: %w(admin)) }

        users.each do |user|
          puts "generated #{user.full_name} : #{user.email}"
        end
      end

      count_per_user = args[:total].to_i / users.size

      puts "creating at most #{args[:total]} users"
      puts "down to #{args[:levels]} levels"

      remainders = users.map do |user|
        puts "Generating #{count_per_user} users in the downline of #{user.full_name}"
        generate_downline(user, args[:levels].to_i, args[:per_user].to_i, count_per_user)
      end

      total = args[:total].to_i - remainders.inject(:+)

      puts "created #{total} users"
    end

    def get_random_percentage_of_users(percentage)
      User.all.select { rand(1...100) <= percentage }.entries
    end

    def random_order_date(start_date, days)
      days_from_start = rand(0...days)
      start_date + days_from_start.days
    end

    def mod?(n = 2)
      DateTime.current.to_i % n == 0
    end

    task :orders, [ :per_user, :months_back ] => :environment do |_t, args|
      Order.destroy_all
      Quote.destroy_all
      Customer.destroy_all

      user_count = User.count
      args.with_defaults(per_user: 10, months_back: 2)

      start_date = (DateTime.current - args[:months_back].to_i.months).beginning_of_month
      end_date = DateTime.current
      days_from_start = end_date.mjd - start_date.mjd

      users = get_random_percentage_of_users(90)
      puts "Creating #{users.size} purchases of the Cert Product out of #{user_count} users"

      users.each do |user|
        order_date =  random_order_date(start_date, 30)
        Order.create!(user:       user,
                      product_id: CERT_ITEM_ID,
                      order_date: order_date,
                      customer:   user.make_customer!)
      end

      puts "Creating an average of #{args[:per_user]} orders per user between dates #{start_date} and #{end_date}"

      utilities = QuoteField.find_by(name: 'utility').lookups.map(&:id)
      roof_ages = QuoteField.find_by(name: 'roof_age').lookups.map(&:id)
      roof_types = QuoteField.find_by(name: 'roof_type').lookups.map(&:id)

      User.all.each do |user|
        order_amount = rand(0...args[:per_user].to_i * 3)
        puts "Creating #{order_amount} Solar Item order(s) for user #{user.full_name}"
        0.upto(order_amount) do |_i|
          customer = Customer.create!(
            email:      Faker::Internet.email,
            first_name: Faker::Name.first_name,
            last_name:  Faker::Name.last_name,
            phone:      Faker::PhoneNumber.phone_number,
            address:    Faker::Address.street_address,
            city:       Faker::Address.city,
            state:      Faker::Address.state_abbr,
            zip:        Faker::Address.zip)

          data = {
            'credit_score_qualified' => true,
            'average_bill'           => rand(100) + 100 }

          data['square_feet'] = rand(1000) + 1000
          data['utility'] = utilities[rand(utilities.size)]
          data['roof_age'] = roof_ages[rand(roof_ages.size)]
          data['roof_type'] = roof_types[rand(roof_types.size)]

          quote = Quote.create!(product_id: SOLAR_ITEM_ID, user: user, customer: customer, data: data)
          order_date =  random_order_date(start_date, days_from_start)
          Order.create!(user: user, product_id: SOLAR_ITEM_ID, order_date: order_date, customer: customer, quote: quote)
        end
      end

      PayPeriod.generate_missing
    end
  end
end

namespace :powur do
  namespace :simulate do

    def generate_user(attrs = {})
      attrs = {
        password:              'solarpower',
        password_confirmation: 'solarpower',
        tos:                   true,
        email:                 Faker::Internet.email,
        first_name:            Faker::Name.first_name,
        last_name:             Faker::Name.last_name,
        phone:                 Faker::PhoneNumber.phone_number,
        zip:                   Faker::Address.zip,
        address:               Faker::Address.street_address,
        city:                  Faker::Address.city,
        state:                 Faker::Address.state,
        lifetime_rank: 1 }.merge(attrs)

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

    task :quotes, [ :per_user, :months_back ] => :environment do |_t, args|
      Quote.destroy_all
      Customer.destroy_all

      user_count = User.count
      args.with_defaults(per_user: 5, months_back: 2)

      start_date = (DateTime.current - args[:months_back].to_i.months).beginning_of_month
      end_date = DateTime.current
      days_from_start = end_date.mjd - start_date.mjd

      users = get_random_percentage_of_users(80)
      puts "Creating #{users.size} purchases of the Cert Product out of #{user_count} users"

      User.all.each do |user|
        count = rand(0...args[:per_user].to_i * 3)
        puts "Creating #{count} Solar Item quotes(s) for user #{user.full_name}"
        0.upto(count) do |_i|
          customer = Customer.create!(
            email:      Faker::Internet.email,
            first_name: Faker::Name.first_name,
            last_name:  Faker::Name.last_name,
            phone:      Faker::PhoneNumber.phone_number,
            address:    Faker::Address.street_address,
            city:       Faker::Address.city,
            state:      Faker::Address.state,
            zip:        Faker::Address.zip)

          data = { 'average_bill' => rand(100) + 100 }

          quote = Quote.create!(product_id: SOLAR_ITEM_ID, user: user, customer: customer, data: data)
        end
      end

      PayPeriod.generate_missing
    end
  end
end

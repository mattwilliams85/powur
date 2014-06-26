namespace :sunstand do
  namespace :simulate do

    def generate_user(attrs = {})
      attrs = {
        password:   'solarpower',
        email:      Faker::Internet.email,
        first_name: Faker::Name.first_name,
        last_name:  Faker::Name.last_name,
        phone:      Faker::PhoneNumber.phone_number,
        zip:        Faker::Address.zip,
        address:    Faker::Address.street_address,
        city:       Faker::Address.city,
        state:      Faker::Address.state_abbr }.merge(attrs)

      User.create!(attrs)
    end

    def generate_downline(user, levels, per_user, max_users)
      return max_users if max_users.zero? || levels.zero?
      per_user = max_users if max_users < per_user

      children = 1.upto(rand(0..per_user)).map do |i|
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

    task :users, [ :total, :per_user, :levels ] => :environment do |t, args|
      args.with_defaults(total: 1000, per_user: 20, levels: 3 )

      users = User.all.to_a

      if users.empty?
        puts "no users found generating 5 root admin users"
        users = 1.upto(5).map { |i| generate_user(roles: %w(admin)) }
        
        users.each do |user| 
          puts "generated #{user.full_name} : #{user.email}"
        end
      end

      count_per_user = args[:total] / users.size

      puts "creating at most #{args[:total]} users"
      puts "down to #{args[:levels]} levels"

      remainders = users.map do |user|
        puts "Generating #{count_per_user} users in the downline of #{user.full_name}"
        generate_downline(user, args[:levels], args[:per_user], count_per_user)
      end

      total = args[:total] - remainders.inject(:+)

      puts "created #{total} users"
    end
  end
end
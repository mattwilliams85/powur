namespace :powur do
  task prepare_data_for_testing: :environment do
    def with_csv(file)
      path = Rails.root.join('db', 'seed', "#{file}.csv")
      csv = CSV.read(path)
      headers = csv.shift
      csv.each do |row|
        yield(row, headers) if block_given?
      end
    end

    def attrs_from_csv_row(row)
      attrs = { first_name: row[0].strip,
                last_name:  row[1].strip,
                email:      row[2].strip.downcase,
                smarteru_employee_id: row[4]}
      attrs[:roles] = [ 'admin' ] if row[3] == 'admin'
      attrs
    end

    new_password = 'solarpower'

    # Update user emails/passwords
    User.find_each do |user|
      next if user.email.match(/eyecue/)

      user.update_attributes(
        email:                 "development+#{user.id}@eyecuelab.com",
        phone:                 nil,
        password:              new_password,
        password_confirmation: new_password)
    end

    # Create testing accounts
    with_csv('eyecue_users') do |row|
      attrs = attrs_from_csv_row(row)

      next if User.find_by(email: attrs[:email])

      attrs.merge!(password: new_password, password_confirmation: new_password)
      user = User.create!(attrs)
      puts "Created user #{user.id} : #{user.full_name}"
    end
  end
end

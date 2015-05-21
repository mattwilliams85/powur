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

    def move_user(user, placement_id)
      parent = User.find(placement_id)
      User.move_user(user, parent)
      puts "Moved user #{user.id} : #{user.full_name} to new parent #{placement_id}"
    end

    def attrs_from_csv_row(row)
      attrs = { id:         row[0].to_i,
                first_name: row[3].strip,
                last_name:  row[4].strip,
                phone:      row[5] && row[5].strip,
                email:      row[6].strip.downcase,
                address:    row[7] && row[7].strip,
                city:       row[8] && row[8].strip,
                state:      row[9] && row[9].strip,
                zip:        row[10] && row[10].strip }
      attrs[:sponsor_id] = row[1].to_i if row[1]
      attrs[:roles] = [ 'admin' ] if row[11] == 'admin'
      attrs
    end

    task advocates: :environment do
      User.update_all(sponsor_id: nil)
      User.destroy_all

      with_csv('advocates') do |row|
        attrs = attrs_from_csv_row(row)

        user = User.find_by(id: attrs[:id])
        if user
          user.update_attributes(attrs)
          puts "Updated user #{user.id} : #{user.full_name}"
          move_user(user, row[2].to_i) if row[2] && row[2] != row[1]
          next
        end

        first = attrs[:first_name].split(' ').first.downcase
        last = attrs[:id].to_s
        password = [ 'solar', first, last ].join('!')
        attrs.merge!(
          password:              password,
          password_confirmation: password,
          tos:                   true)

        user = User.create!(attrs)
        puts "Created user #{user.id} : #{user.full_name}"
        move_user(user, row[2].to_i) if row[2] && row[2] != row[1]
      end

    end

    task nmi: :environment do
      User.where(id: 25).destroy_all

      password = 'sunlight'
      attrs = {
        id:                    25,
        first_name:            'Nmi',
        last_name:             'User',
        email:                 'nmi@powur.com',
        tos:                   true,
        password:              password,
        password_confirmation: password }
      User.create!(attrs)

      puts 'Created NMI user account'
    end

    task ipayout: :environment do
      User.where(id: 25).destroy_all

      password = 'sunlight'
      attrs = {
        id:                    26,
        first_name:            'iPayout',
        last_name:             'User',
        email:                 'ipayout@powur.com',
        tos:                   true,
        password:              password,
        password_confirmation: password }
      User.create!(attrs)

      puts 'Created iPayout user account'
    end

  end
end

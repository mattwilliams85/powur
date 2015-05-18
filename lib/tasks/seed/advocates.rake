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

    task advocates: :environment do
      User.update_all(sponsor_id: nil)
      User.destroy_all

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

  end
end

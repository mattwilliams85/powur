namespace :powur do
  namespace :import do

    def last_advocate_file
      Dir[Rails.root.join('db', 'import', '*.csv')].sort.last
    end

    def merge_address(attrs, row)
      %w(address city state zip).each_with_index do |attr, i|
        value = row[7 + i].presence
        attrs[attr] = value.strip if value
      end
    end

    def attrs_from_row(row)
      attrs = {
        first_name:            row[3].strip,
        last_name:             row[4].strip,
        phone:                 row[5].presence && row[5].strip,
        email:                 row[6].strip,
        password:              row[12].strip,
        password_confirmation: row[12].strip }
      merge_address(attrs, row)
      attrs
    end

    def create_user(row)
      id = row[0].to_i
      return if User.exists?(id)

      sponsor_id = row[1].to_i
      placement_id = row[2].to_i

      sponsor = User.find(sponsor_id)
      placement = sponsor_id == placement_id ? sponsor : User.find(placement_id)

      attrs = attrs_from_row(row)
      attrs.merge!(
        id:         id,
        sponsor_id: sponsor_id)
      user = User.create!(attrs)
      puts "Created user #{user.full_name} : #{user.id}"

      return if placement_id == sponsor_id
      User.move_user(user, placement)
      puts "Placed user to #{placement.full_name} : #{placement.id}"
    end

    task advocates: :environment do
      path = last_advocate_file
      if path.nil?
        puts 'No file found to import'
        return
      end

      unless File.exists?(path)
        puts "No file found at path #{path}"
        return
      end

      puts "importing advocates from file #{path}"
      data = CSV.read(path)
      data.shift

      data.each do |row|
        create_user(row)
      end
    end

  end
end

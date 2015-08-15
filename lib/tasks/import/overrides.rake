namespace :powur do
  namespace :overrides do
    def file_path(file, type = :csv)
      Rails.root.join('db', 'overrides', "#{file}.#{type}").to_s
    end

    def load_yaml(file)
      YAML.load_file(file_path(file))
    end

    def load_csv(file)
      csv = CSV.read(file_path(file))
      csv.shift
      csv
    end

    def ranks_data
      @ranks_data ||= load_csv('ranks')
    end

    def sponsors_data
      @sponsors_data ||= load_csv('sponsors')
    end

    task sponsors: :environment do
      sponsors_data.each do |row|
        user, sponsor_id = User.find(row[0].to_i), row[1].to_i
        next if user.sponsor_id == sponsor_id
        puts "updating sponsor for #{user.full_name} : #{user.id} to #{sponsor_id}"
        user.update_attribute(:sponsor_id, sponsor_id)
      end
    end

    task ranks: :environment do
      ranks_data.each do |row|
        attrs = {
          user_id:    row[0].to_i,
          kind:       :pay_as_rank,
          rank:       row[1].to_i,
          start_date: Date.strptime(row[2], '%m/%d/%Y'),
          end_date:   Date.strptime(row[3], '%m/%d/%Y') }
        UserOverride.send(attrs[:kind])
          .where(user_id: attrs[:user_id]).delete_all
        puts "Creating rank override for user #{attrs[:user_id]}"
        UserOverride.create!(attrs)
      end
    end
  end
end

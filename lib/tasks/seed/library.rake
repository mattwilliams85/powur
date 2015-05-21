namespace :powur do
  namespace :seed do
    def with_csv(file)
      path = Rails.root.join('db', 'seed', "#{file}.csv")
      csv = CSV.read(path)
      headers = csv.shift
      csv.each do |row|
        yield(row, headers)
      end
    end

    def bool_value(value)
      ![ 0, '0', 'false', 'FALSE', nil, 'no' ].include?(value)
    end

    task library: :environment do
      Resource.destroy_all
      with_csv('library') do |row, _headers|
        attrs = {
          id: row[0].to_i,
          user_id: row[1].to_i,
          title: row[2],
          description: row[3],
          file_original_path: row[4],
          is_public: bool_value(row[5])
        }

        resource = Resource.create!(attrs)
        puts "Created library resource #{resource.title} : #{resource.id}"
      end
    end
  end
end

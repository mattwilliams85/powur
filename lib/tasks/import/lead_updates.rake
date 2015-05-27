namespace :powur do
  namespace :import do

    def last_file
      Dir[Rails.root.join('db', 'lead_updates', '*.csv')].last
    end

    task lead_updates: :environment do
      path = ENV['LEAD_UPDATE'] || last_file
      if path.nil?
        puts 'No file found to import'
        return
      end 

      if !File.exists?(path)
        puts "No file found at path #{path}"
        return
      end

      puts "Importing lead update file #{path}"
      data = CSV.read(path)
      LeadUpdate.create_from_csv(data)
    end
  end
end

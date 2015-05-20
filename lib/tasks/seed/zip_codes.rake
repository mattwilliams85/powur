namespace :powur do
  namespace :seed do

    task zip_codes: :environment do
      Zipcode.destroy_all

      path = Rails.root.join('db', 'seed', 'zip_codes.txt')
      File.open(path, 'r').each_with_index do |line, i|
        Zipcode.create(zip: line.strip)
        puts "Created #{i} zip codes..." if i % 100 == 0
      end

      puts 'Created SolarCity ZIP Codes...'
    end

  end
end

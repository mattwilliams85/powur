namespace :powur do
  namespace :seed do

    task zip_codes: :environment do
      Zipcode.destroy_all

      path = Rails.root.join('db', 'seed', 'zip_codes.txt')
      File.open(path, 'r').each_line do |line|
        Zipcode.create(zip: line.strip)
      end

      puts 'Created SolarCity ZIP Codes...'
    end

  end
end

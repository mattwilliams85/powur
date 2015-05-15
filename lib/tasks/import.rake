namespace :powur do
  namespace :import do

    def push_lookups(path)
      filename = File.basename(path)
      parts = filename.split('_')
      product_id = parts.first.to_i
      fail "Invalid file name #{path}" if product_id == 0

      field_name = File.basename(parts[1..-1].join('_'), '.*')
      field = QuoteField.where(product_id: product_id, name: field_name).first
      unless field
        fail "Invalid product id: #{product_id} or field name: #{field_name}"
      end

      field.lookups_from_csv(File.read(path))
    rescue => e
      puts e
    end

    task quote_field_lookups: :environment do
      files  = Dir[Rails.root.join('db/lookups/*.csv')]
      files.each do |path|
        push_lookups(path)
      end
    end

    task zipcodes: :environment do
      puts 'Seeding SolarCity ZIP Codes...'
      Zipcode.destroy_all

      arr_of_arrs = CSV.read("lib/assets/solarcity_zip_codes.csv")

      arr_of_arrs.each do |zip|
        Zipcode.create({zip: zip.first})
      end

      puts 'Finished Seeding SolarCity ZIP Codes'
    end
  end
end

namespace :powur do
  namespace :seed do

    SOLAR_PRODUCT_FIELDS = [
      { name:      'average_bill',
        data_type: :number,
        required:  false } ]

    def with_csv(file)
      path = Rails.root.join('db', 'seed', "#{file}.csv")
      csv = CSV.read(path)
      headers = csv.shift
      csv.each do |row|
        yield(row, headers) if block_given?
      end
    end

    def bool_value(value)
      ![ 0, '0', 'false', 'FALSE', nil, 'no' ].include?(value)
    end

    task products: :environment do
      Product.destroy_all

      with_csv('products') do |row, _headers|
        attrs = {
          id: row[0].to_i,
          name: row[1],
          description: row[2],
          long_description: row[3],
          bonus_volume: row[4].to_i,
          commission_percentage: row[5].to_i,
          distributor_only: bool_value(row[6]),
          certifiable: bool_value(row[7]),
          image_original_path: row[8],
          smarteru_module_id: row[9] && row[9].to_s,
          is_required_class: bool_value(row[10]),
          position: row[11] && row[11].to_i }

        product = Product.create!(attrs)
        puts "Created product #{product.name} : #{product.id}"
      end

      product = Product.find(1)
      SOLAR_PRODUCT_FIELDS.each do |attrs|
        product.quote_fields.create!(attrs)
      end
    end

  end
end

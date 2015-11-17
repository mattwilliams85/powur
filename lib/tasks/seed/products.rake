namespace :powur do
  namespace :seed do
    def load_yaml(file_name)
      YAML.load_file(Rails.root.join('db', 'seed', "#{file_name}.yml"))
    end

    task products: :environment do
      Product.destroy_all
      load_yaml('products')['products'].each do |attrs|
        product = Product.create(attrs)
        puts "Created product #{product.id} : #{product.name}"
      end
    end
  end
end

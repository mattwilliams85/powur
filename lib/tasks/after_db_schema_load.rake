
namespace :sunstand do
  namespace :db do
    task :after_schema_load => :environment do

      puts 'Adding primary key for :invites'
      query = 'alter table invites add primary key (id);'
      ActiveRecord::Base.connection.execute(query)

      puts 'Adding primary key for :ranks'
      query = 'alter table ranks add primary key (id);'
      ActiveRecord::Base.connection.execute(query)

      puts 'Adding primary key for :bonus_sales_requirements'
      query = 'alter table bonus_sales_requirements add primary key (bonus_id, product_id);'
      ActiveRecord::Base.connection.execute(query)

      puts 'Adding primary key for :bonus_levels'
      query = 'alter table bonus_levels add primary key (bonus_id, level);'
      ActiveRecord::Base.connection.execute(query)

      puts 'Adding primary key for :pay_periods'
      query = 'alter table pay_periods add primary key (id);'
      ActiveRecord::Base.connection.execute(query)

      puts 'Adding primary key for :bonus_payment_orders'
      query = 'alter table bonus_payment_orders add primary key (bonus_payment_id, order_id);'
      ActiveRecord::Base.connection.execute(query)
    end
  end
end

Rake::Task['db:schema:load'].enhance do
  ::Rake::Task['sunstand:db:after_schema_load'].invoke
end

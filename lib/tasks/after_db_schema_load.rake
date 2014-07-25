
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

      puts 'Adding primary key for :bonus_rank_amounts'
      query = 'alter table bonus_levels add primary key (bonus_id, level);'
      ActiveRecord::Base.connection.execute(query)

    end
  end
end

Rake::Task['db:schema:load'].enhance do
  ::Rake::Task['sunstand:db:after_schema_load'].invoke
end


namespace :sunstand do
  namespace :db do
    task :after_schema_load => :environment do
      puts 'Adding primary key for :invites'
      query = 'alter table invites add primary key (id);'
      ActiveRecord::Base.connection.execute(query)
    end
  end
end

Rake::Task['db:schema:load'].enhance do
  ::Rake::Task['sunstand:db:after_schema_load'].invoke
end
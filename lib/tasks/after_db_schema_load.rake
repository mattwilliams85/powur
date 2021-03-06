
namespace :powur do
  namespace :db do
    def execute(query)
      ActiveRecord::Base.connection.execute(query)
    end

    task after_schema_load: :environment do
      puts 'Adding primary key for :utilities'
      execute 'alter table utilities add primary key (id);'

      puts 'Adding primary key for :invites'
      execute 'alter table invites add primary key (id);'

      puts 'Adding primary key for :ranks'
      execute 'alter table ranks add primary key (id);'

      puts 'Adding primary key for :pay_periods'
      execute 'alter table pay_periods add primary key (id);'

      puts 'Adding primary key for :bonus_payment_leads'
      execute 'alter table bonus_payment_leads
               add primary key (bonus_payment_id, lead_id);'

      puts 'Adding primary key for :api_clients'
      execute 'alter table api_tokens add primary key (id);'

      puts 'Adding primary key for :api_tokens'
      execute 'alter table api_tokens add primary key (id);'
    end
  end
end

Rake::Task['db:schema:load'].enhance do
  ::Rake::Task['powur:db:after_schema_load'].invoke
end

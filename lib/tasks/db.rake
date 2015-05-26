namespace :powur do
  namespace :db do
    TABLES = %w(quotes users)

    def execute(sql)
      ActiveRecord::Base.connection.execute(sql)
    end

    task reset_auto_ids: :environment do
      TABLES.each do |table|
        sql = "select id from #{table} order by id desc limit 1;"
        result = execute(sql)
        next unless result.any?
        next_id = result.first['id'].to_i + 1
        sql = "alter sequence #{table}_id_seq restart with #{next_id}"
        execute(sql)
      end
    end
  end
end

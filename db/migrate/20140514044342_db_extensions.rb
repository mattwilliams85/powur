class DbExtensions < ActiveRecord::Migration
  def change
    execute 'create extension pg_trgm;'
    execute 'create extension hstore;'
  end
end

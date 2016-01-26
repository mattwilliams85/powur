class CompPlanV5 < ActiveRecord::Migration
  def up
    add_column :rank_requirements,
               :lead_status,
               :integer,
               null:    false,
               default: 1
    add_column :rank_requirements, :leg_count, :integer
    add_column :rank_requirements, :team, :boolean, null: false, default: false

    drop_table :lead_totals
    create_table :user_totals, id: false do |t|
      t.integer :id, null: false
      t.jsonb :lifetime_leads, default: {}
      t.jsonb :monthly_leads, default: {}
      t.jsonb :team_leads, default: {}
      t.jsonb :monthly_team_leads, default: {}
    end
    add_foreign_key :user_totals, :users, column: :id
    execute 'alter table user_totals add primary key (id);'

    remove_column :rank_requirements, :event_type
    remove_foreign_key :bonus_payments, column: :pay_as_rank
    remove_foreign_key :ranks_user_groups, :ranks
    remove_foreign_key :rank_requirements, :ranks
    Rake::Task['powur:seed:ranks'].invoke(5)

    puts 'Calculating user totals...'
    UserTotals.calculate_all
    puts 'Ranking users...'
    Rank.rank_users(MonthlyPayPeriod.current_id)
  end
end

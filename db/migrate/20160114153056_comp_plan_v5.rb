class CompPlanV5 < ActiveRecord::Migration
  def change
    add_column :rank_requirements,
               :lead_status,
               :integer,
               null:    false,
               default: 1
    add_column :rank_requirements, :leg_count, :integer
    add_column :rank_requirements, :team, :boolean, null: false, default: false
    add_column :lead_totals, :team_counts, :integer, array: true

    reversible do |dir|
      dir.up do
        remove_column :rank_requirements, :event_type
        remove_foreign_key :bonus_payments, column: :pay_as_rank
        remove_foreign_key :ranks_user_groups, :ranks
        remove_foreign_key :rank_requirements, :ranks
        Rake::Task['powur:seed:ranks'].invoke(5)
      end
      dir.down do
        add_column :rank_requirements, :event_type, :integer,
                   null:    false,
                   default: 1
        Rake::Task['powur:seed:ranks'].invoke(4)
        add_foreign_key :bonus_payments, :ranks,
                        column:      :pay_as_rank,
                        foreign_key: :id
        add_foreign_key :ranks_user_groups, :ranks, column: :rank_id
        add_foreign_key :rank_requirements, :ranks, column: :rank_id
      end
    end

    LeadTotals.calculate_latest
    Rank.rank_users
  end
end

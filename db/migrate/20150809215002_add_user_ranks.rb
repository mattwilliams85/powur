class AddUserRanks < ActiveRecord::Migration
  def change
    create_table :user_ranks, id: false do |t|
      t.references :user, null: false
      t.references :rank, null: false
      t.string :pay_period_id, null: false

      t.foreign_key :users
      t.foreign_key :ranks
      t.foreign_key :pay_periods
    end
    reversible do |dir|
      dir.up do
        execute 'alter table user_ranks add primary key (user_id, rank_id, pay_period_id);'
      end
    end

    create_table :rank_requirements do |t|
      t.references :rank, null: false
      t.references :product, null: false
      t.integer :event_type, null: false
      t.integer :time_span, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :max_leg
      t.string  :type, null: false

      t.foreign_key :ranks
      t.foreign_key :products
    end

    reversible do |dir|
      dir.up do
        UserGroupRequirement.all.each do |req|
          group = UserGroup.find(req.user_group_id)
          rank_id = group.ranks.first.id
          attrs = {
            rank_id:    rank_id,
            product_id: req.product_id,
            event_type: req.event_type,
            time_span:  req.time_span || 2,
            quantity:   req.quantity,
            max_leg:    req.max_leg,
            type:       req.type }
          RankRequirement.create!(attrs)
        end
      end
    end
  end
end

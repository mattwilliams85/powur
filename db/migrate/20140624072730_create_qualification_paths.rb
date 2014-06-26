class CreateQualificationPaths < ActiveRecord::Migration
  def change
    create_table :qualification_paths do |t|
      t.string :title, null: false
    end
  end
end

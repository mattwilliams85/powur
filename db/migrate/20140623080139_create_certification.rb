class CreateCertification < ActiveRecord::Migration
  def change
    create_table :certifications do |t|
      t.string :title, null: false
    end
  end
end

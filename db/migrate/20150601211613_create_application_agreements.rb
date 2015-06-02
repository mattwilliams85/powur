class CreateApplicationAgreements < ActiveRecord::Migration
  def change
    create_table :application_agreements do |t|
      t.string :version
      t.string :document_path
      t.datetime :published_at
      t.timestamps
    end
  end
end

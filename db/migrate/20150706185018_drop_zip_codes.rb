class DropZipCodes < ActiveRecord::Migration
  def change
    drop_table :zipcodes
  end
end

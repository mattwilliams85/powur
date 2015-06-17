class RenameCertifiableToUniversityClass < ActiveRecord::Migration
  def change
    rename_column :products, :certifiable, :is_university_class
  end
end

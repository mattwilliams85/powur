class CreateSocialMediaPosts < ActiveRecord::Migration
  def change
    create_table :social_media_posts do |t|
      t.string :content
      t.boolean :publish
      t.timestamps
    end
  end
end

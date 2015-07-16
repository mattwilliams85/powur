class AddJourneyClassProduct < ActiveRecord::Migration
  def up
    Product.create(
      id:                  4,
      name:                'Journey to Game Changer',
      description:         '',
      long_description:    '',
      bonus_volume:        0,
      distributor_only:    true,
      is_university_class: true,
      is_required_class:   false,
      image_original_path: 'https://sunstand-dev.s3.amazonaws.com/product_original_images/7e8ea17f8e945778dcf9304243fbc4e2/game-changer-class.jpg',
      smarteru_module_id:  '10943',
      position:            3
    )
  end

  def down
  end
end

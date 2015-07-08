university_classes_json.item_init(local_assigns[:rel] || 'item')
university_classes_json.list_item_properties(university_class)

actions \
  action(:enroll, :post, enroll_university_class_path(university_class)),
  action(:smarteru_signin, :post, smarteru_signin_university_class_path(university_class)),
  action(:purchase, :post, purchase_university_class_path(university_class))

links \
  link(:self, university_class_path(university_class))

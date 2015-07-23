json.properties do
  json.call(university_class,
            :id, :name, :description, :long_description,
            :topic, :is_required_class, :slug)

  json.image_url university_class.image_original_path
  json.price university_class.bonus_volume
  json.purchased university_class.purchased_by?(current_user.id)
  json.enrollable !!university_class.smarteru_module_id
  json.state current_user.product_enrollments.find_by(product_id: university_class.id).try(:state)
  if university_class.prerequisite &&
      !university_class.prerequisites_taken?(current_user)
    json.prerequisite(
      id:   university_class.prerequisite.id,
      name: university_class.prerequisite.name)
  end
end

actions \
  action(:enroll, :post, enroll_university_class_path(university_class)),
  action(:smarteru_signin, :post, smarteru_signin_university_class_path(university_class)),
  action(:purchase, :post, purchase_university_class_path(university_class)),
  action(:check_enrollment, :get, check_enrollment_university_class_path(university_class))

links \
  link(:self, university_class_path(university_class))

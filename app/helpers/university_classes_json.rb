class UniversityClassesJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :university_classes, :list

    list_entities(partial_path)
  end

  def item_init(rel = nil)
    klass :university_class

    entity_rel(rel) if rel
  end

  def list_item_properties(university_class = @item)
    json.properties do
      json.id university_class.id
      json.name university_class.name
      json.description university_class.description
      json.image_url university_class.image_original_path
      json.price university_class.bonus_volume
      json.purchased university_class.purchased_by?(current_user.id)
      json.enrollable !!university_class.smarteru_module_id
    end
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :university_class
  end
end

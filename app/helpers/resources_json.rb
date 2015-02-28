class ResourcesJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :resources, :list

    list_entities(partial_path)
  end

  def item_init(rel = nil)
    klass :resource

    entity_rel(rel) if rel
  end

  def list_item_properties(resource = @item)
    json.properties do
      json.id resource.id
      json.user_id resource.user_id
      json.title resource.title
      json.description resource.description
      json.file_original_path resource.file_original_path
      json.file_type resource.file_type
      json.is_public !!resource.is_public
    end
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :resource
  end
end

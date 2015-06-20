class InvitesJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :invites, :list

    list_entities(partial_path)
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :invite
  end

  def item_init(rel = nil)
    klass :user

    entity_rel(rel) if rel
  end
end

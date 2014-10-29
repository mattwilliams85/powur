class RanksJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :ranks, :list

    list_entities(partial_path)
  end

  def item_init(rel = nil)
    klass :rank

    entity_rel(rel) if rel
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :rank
  end

  def properties(rank = @item)
    json.properties do
      json.call(rank, :id, :title)
    end
  end

  def admin_entities(rank = @item)
    return if rank.id == 1
    entities entity('admin/qualifications/rank_index',
                    'rank-qualifications',
                    rank:           rank,
                    qualifications: rank.qualifications)
  end

  def admin_item_actions(rank = @item)
    list = [ action(:update, :patch, rank_path(rank))
      .field(:title, :text, value: rank.title) ]
    list << action(:delete, :delete, rank_path(rank)) if rank.last_rank?
    actions(*list)
  end

  def create_action
    action(:create, :post, ranks_path).field(:title, :text)
  end
end
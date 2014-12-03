class RanksJson < JsonDecorator
  def item_init(rel = nil)
    klass :rank

    entity_rel(rel) if rel
  end

  def list_entities(partial_path = 'item', list = @list)
    json.entities list, partial: partial_path, as: :rank
  end

  def properties(rank = @item)
    json.properties do
      json.call(rank, :id, :title)
    end
  end

  def rank_entities(rank, qual_path)
    return if rank.id == 1
    entities entity(qual_path,
                    'rank-qualifications',
                    rank:           rank,
                    qualifications: rank.qualifications)
  end

  def admin_entities(rank = @item)
    rank_entities(rank, 'admin/qualifications/rank_index')
  end

  def user_entities(rank = @item)
    rank_entities(rank, 'auth/qualifications/index')
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

class JsonDecorator < SimpleDelegator
  def initialize(view, list, item)
    super(view)
    @list, @item = list, item
  end

  def rank_path_field(action)
    options = Hash[all_paths.map { |p| [ p.id, p.name ] }]
    action.field(:rank_path_id, :select, options: options)
  end
end

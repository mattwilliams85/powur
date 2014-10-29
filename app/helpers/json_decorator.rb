class JsonDecorator < SimpleDelegator
  def initialize(view, list, item)
    super(view)
    @list, @item = list, item
  end
end

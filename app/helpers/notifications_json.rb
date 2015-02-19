class NotificationsJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :notifications, :list

    list_entities(partial_path)
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :notification
  end
end

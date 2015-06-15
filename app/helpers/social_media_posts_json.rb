class SocialMediaPostsJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :social_media_posts, :list

    list_entities(partial_path)
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :social_media_post
  end
end

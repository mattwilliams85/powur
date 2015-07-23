module Auth
  class SocialMediaPostsController < AuthController

    def index
      @social_media_posts = SocialMediaPost.where(publish: true)
    end

  end
end

module Auth
  class SocialMediaPostsController < AuthController

    def index
      respond_to do |format|
        format.html
        format.json do
          @social_media_posts = SocialMediaPost.where(publish: true)
        end
      end
    end

  end
end
module Auth
  class SocialMediaPostsController < AuthController
    page max_limit: 1

    def index
      respond_to do |format|
        format.html
        format.json do
          @social_media_posts = apply_list_query_options(SocialMediaPost)
        end
      end
    end

  end
end
module Admin
  class SocialMediaPostsController < AdminController
    page max_limit: 10

    def index
      respond_to do |format|
        format.html
        format.json do
          @social_media_posts = apply_list_query_options(SocialMediaPost)
        end
      end
    end

    def create
      @social_media_post = SocialMediaPost.create(input)
      render 'index'
    end

    def destroy
      @social_media_post = SocialMediaPost.find(params[:id])

      @social_media_post.destroy!
      @social_media_posts = SocialMediaPost.all

      render 'index'
    end

    def show
      @social_media_post = SocialMediaPost.find(params[:id])
    end

    def update
      @social_media_post = SocialMediaPost.find(params[:id])
      @social_media_post.update_attributes!(input)

      render 'index'
    end

    private

    def input
      allow_input(:content, :published)
    end
  end
end

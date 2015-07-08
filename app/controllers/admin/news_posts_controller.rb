module Admin
  class NewsPostsController < AdminController
    page
    sort id_desc: { id: :desc },
         id_asc:  { id: :asc }

    before_filter :fetch_post, only: [:show, :update, :destroy ]

    def index
      @posts = apply_list_query_options(NewsPost)
      render :index
    end

    def create
      @post = NewsPost.create(input)
      index
    end

    def destroy
      @post.destroy!
      index
    end

    def show
    end

    def update
      @post.update_attributes!(input)
      index
    end

    private

    def fetch_post
      @post = NewsPost.find(params[:id])
    end

    def input
      allow_input(:content)
    end
  end
end

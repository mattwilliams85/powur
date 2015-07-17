module Auth
  class NewsPostsController < AuthController
    page max_limit: 3
    sort id:  { id: :desc }

    def index
      @news_posts = apply_list_query_options(NewsPost)
    end
  end
end

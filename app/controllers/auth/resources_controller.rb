module Auth
  class ResourcesController < AuthController
    page
    sort id:  { id: :desc }

    before_filter :find_resource, only: [:show]

    def index
      @resources = apply_list_query_options(Resource.published)
    end

    def videos
      @resources = apply_list_query_options(Resource.published.videos)
      render :index
    end

    def documents
      @resources = apply_list_query_options(Resource.published.documents)
      render :index
    end

    private

    def find_resource
      @resource = Resource.published.find(params[:id])
    end
  end
end

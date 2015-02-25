module Auth
  class ResourcesController < AuthController
    page

    before_filter :find_resource, only: [:show]

    def index
      @resources = apply_list_query_options(Resource.published)
    end

    private

    def find_resource
      @resource = Resource.published.find(params[:id])
    end
  end
end

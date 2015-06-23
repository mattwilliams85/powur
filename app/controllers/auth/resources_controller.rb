module Auth
  class ResourcesController < AuthController
    page
    sort id:  { id: :desc }

    before_filter :find_resource, only: [:show]

    def index
      scope = Resource.published.sorted.with_topics
      scope = scope.search(params[:search]) if params[:search].present?
      scope = scope.videos if params[:type] == 'videos'
      scope = scope.documents if params[:type] == 'documents'
      @resources = apply_list_query_options(scope)
      @topics = @resources.map(&:topic).uniq.sort do |a, b|
        a.position <=> b.position
      end
    end

    private

    def find_resource
      @resource = Resource.published.find(params[:id])
    end
  end
end

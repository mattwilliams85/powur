module Admin
  class ResourceTopicsController < AdminController
    page
    sort position: { position: :asc },
         id:       { id: :desc }

    before_action :find_resource_topic, only: [ :show, :destroy, :update ]

    def index
      @resource_topics = apply_list_query_options(ResourceTopic)

      render 'index'
    end

    def create
      @resource_topic = ResourceTopic.create!(input)

      show
    end

    def update
      @resource_topic.update_attributes!(input)

      show
    end

    def show
      render 'show'
    end

    def destroy
      @resource_topic.destroy

      index
    end

    private

    def input
      allow_input(:title, :position)
    end

    def find_resource_topic
      @resource_topic = ResourceTopic.find(params[:id].to_i)
    end
  end
end

module Admin
  class ResourcesController < AdminController
    page

    before_action :find_resource, only: [ :show, :destroy, :update ]

    def index
      @resources = apply_list_query_options(Resource)
      render 'index'
    end

    def show
    end

    def create
      resource = Resource.new(input)
      resource.user_id = current_user.id
      if resource.save
        head 200
      else
        render json: { errors: resource.errors.messages }, status: :unprocessable_entity
      end
    end

    def update
      @resource.update_attributes(input)
      if @resource.valid?
        head 200
      else
        render json: { errors: @resource.errors.messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @resource.destroy!
      head 200
    end

    private

    def input
      allow_input(:title, :description, :is_public, :file_original_path)
    end

    def find_resource
      @resource = Resource.find(params[:id].to_i)
    end
  end
end

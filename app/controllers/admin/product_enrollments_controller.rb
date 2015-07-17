module Admin
  class ProductEnrollmentsController < AdminController
    page
    sort date_desc: { updated_at: :desc },
         date_asc:  { updated_at: :asc },
         product_id_asc:   { product_id: :asc },
         product_id_desc:  { product_id: :desc },
         id_asc:         { id: :asc },
         id_desc:        { id: :desc },
         state_asc: { state: :asc },
         state_desc: { state: :desc }

    before_filter :fetch_user, only: [ :index ]

    def index
      scope = ProductEnrollment
      scope = @user.product_enrollments if @user
      scope = scope.search(params[:search]) if params[:search].present?
      @product_enrollments = apply_list_query_options(scope)
      render 'index'
    end

    private

    def fetch_user
      @user = User.find_by_id(params[:admin_user_id].to_i)
    end
  end
end

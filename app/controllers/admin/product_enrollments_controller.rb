module Admin
  class ProductEnrollmentsController < AdminController
    page

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

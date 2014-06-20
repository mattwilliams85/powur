class AdminController < AuthController
  before_filter :has_admin_role

  private

  def has_admin_role
    redirect_to(dashboard_url) unless current_user.has_role?(:admin)
  end

end
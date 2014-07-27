class AdminController < AuthController

  include BonusJSON
  layout 'admin'
  before_action :has_admin_role
  
  private

  def has_admin_role
    redirect_to(dashboard_url) unless current_user.has_role?(:admin)
  end

end
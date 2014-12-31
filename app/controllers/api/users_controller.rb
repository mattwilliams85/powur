module Api
  class UsersController < ApiController
    include UsersActions

    helper_method :user_path

    page
    sort user: 'users.last_name asc, users.first_name asc'

    private

    def user_path(user)
      api_user_path(v: params[:v], id: user)
    end

    class << self
      def controller_path
        'auth/users'
      end
    end
  end
end

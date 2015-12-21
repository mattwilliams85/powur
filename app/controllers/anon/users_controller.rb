module Anon
  class UsersController < AnonController
    before_action :fetch_user, only: [ :show ]

    private

    def fetch_user
      @user = User.partners.find_by(id: params[:id])
      not_found!(:user) if @user.nil?
    end
  end
end

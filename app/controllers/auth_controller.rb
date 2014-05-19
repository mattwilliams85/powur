class AuthController < ApplicationController
  before_filter :authenticate!

  def authenticate!
    unless current_user
      # TODO: implement redirect_to for GET requests
      respond_to do |format|
        format.html { redirect_to login_url }
        format.json { render status: :forbidden, nothing: true }
      end
    end
  end
end
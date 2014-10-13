class AnonController < ApplicationController
  before_action :check_for_incoming_code

  def check_for_incoming_code
    if params[:code] && session[:code] && params[:code] != session[:code]
      session[:code] = nil
    end
  end
end

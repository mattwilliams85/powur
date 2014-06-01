class IndexController < ApplicationController

  layout 'landing'

  def index
    respond_to do |format|
      format.html
      format.json { render "session/#{root_template}" }
    end
  end

  private

  def root_template
    logged_in? ? 'show' : (session[:code] ? 'registration' : 'anonymous')
  end

end

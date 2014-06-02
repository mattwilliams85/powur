class IndexController < ApplicationController

  layout 'landing'

  def index
    respond_to do |format|
      format.html
      format.json { render "session/#{root_template}" }
    end
  end

  private

  def invite? # TODO: put this on anonymous controller
    if session[:code]
      @invite = Invite.find_by(id: session[:code])
      reset_session unless @invite
    end
    !!@invite
  end

  def root_template
    logged_in? ? 'show' : (invite? ? 'registration' : 'anonymous')
  end

end

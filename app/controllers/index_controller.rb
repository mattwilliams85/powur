class IndexController < ApplicationController
  include Anonymous

  layout 'landing'

  def index
    respond_to do |format|
      format.html
      format.json { render "session/#{root_template}" }
    end
  end

  private

  def invite?
    if session[:code]
      @invite = Invite.find_by(id: session[:code])
      session[:code] = nil unless @invite
    end
    !!@invite
  end

  def root_template
    logged_in? ? 'show' : (invite? ? 'registration' : 'anonymous')
  end

end

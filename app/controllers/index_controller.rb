class IndexController < AnonController
  def index
    respond_to do |format|
      format.html
      format.json { render "anon/session/#{json_template}" }
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

  def json_template
    logged_in? ? 'show' : (invite? ? 'registration' : 'anonymous')
  end
end

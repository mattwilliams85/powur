class IndexController < AnonController
  def index
    respond_to do |format|
      format.html { render html_template }
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

  def html_template
    logged_in? ? 'authenticated' : 'anonymous'
  end

  def json_template
    logged_in? ? 'show' : (invite? ? 'registration' : 'anonymous')
  end
end

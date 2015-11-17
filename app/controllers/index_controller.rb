class IndexController < AnonController
  def index
    respond_to do |format|
      format.html
      format.json do
        current_user.update_login_streak!(Time.now.utc) if logged_in?
        render "anon/session/#{json_template}"
      end
    end
  end

  private

  def json_template
    logged_in? ? 'show' : 'anonymous'
  end
end

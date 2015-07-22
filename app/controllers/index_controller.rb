class IndexController < AnonController
  def index
    respond_to do |format|
      format.html
      format.json { render "anon/session/#{json_template}" }
    end
  end

  private

  def json_template
    logged_in? ? 'show' : 'anonymous'
  end
end

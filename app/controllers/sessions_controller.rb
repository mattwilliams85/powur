class SessionsController < WebController
  def show
    render session_template
  end

  private

  def session_template
    logged_in? ? 'authenticated' : 'anonymous'
  end
end

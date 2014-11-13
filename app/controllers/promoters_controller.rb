class PromotersController < AnonController
  layout 'user'

  def thanks
    render layout: 'user'
  end

  def show
  end

  def new
    respond_to do |format|
      format.html
      format.json { "anon/session/registration"}
    end
  end

end

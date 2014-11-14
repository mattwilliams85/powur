class PromotersController < AnonController
  layout 'user'

  def thanks
    render layout: 'user'
  end

  def show
  end

  def new
    @invite = Invite.find_by("id" => params["code"])
    respond_to do |format|
      format.html
      format.json { "anon/session/registration"}
    end
  end

end

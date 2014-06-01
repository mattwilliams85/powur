class PromotersController < ApplicationController

  layout 'user'

  def thanks
    render layout: 'user'
  end

  def show
    respond_to do |format|
      format.json do
        require_input :code

        @invite = Invite.find(params[:code]) or error!(t('errors.invalid_code'), :code)

        render 'users/registration'
      end
    end
  end

end

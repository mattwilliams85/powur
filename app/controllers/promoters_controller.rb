class PromotersController < ApplicationController
  include Anonymous

  layout 'user'

  def thanks
    render layout: 'user'
  end

  def show
  end

end

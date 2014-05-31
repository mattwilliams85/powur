class IndexController < ApplicationController

  layout 'landing'

  def index
  end

  def promoter
    render layout: 'user'
  end

  def customer
  end

end

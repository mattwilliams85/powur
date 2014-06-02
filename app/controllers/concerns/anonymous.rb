module Anonymous
  extend ActiveSupport::Concern

  included do
    before_filter :check_for_incoming_code
  end

  def check_for_incoming_code
    if params[:code] && session[:code] && params[:code] != session[:code]
      session[:code] = nil
    end
  end

end
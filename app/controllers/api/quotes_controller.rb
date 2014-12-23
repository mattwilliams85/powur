module Api
  class QuotesController < ApiController
    include QuotesActions

    helper_method :user_quote_path

    private

    def controller_path
      'auth/quotes'
    end

    def user_quote_path(quote)
      api_quote_path(quote, v: params[:v])
    end

  end
end
module Api
  class QuotesController < ApiController
    include QuotesActions

    helper_method :user_quote_path

    private

    def user_quote_path(quote)
      api_quote_path(id: quote, v: params[:v])
    end

    class << self
      def controller_path
        'auth/quotes'
      end
    end
  end
end

module Auth
  class LeadUpdatesController < AuthController
    before_action :fetch_quote, only: [ :show ]

    def show
      @lead_update = @quote.last_update

      render 'show'
    end

    private

    def fetch_quote
      @quote = Quote.where(
        id: params[:user_quote_id].to_i,
        user_id: current_user.id).first
    end

  end
end

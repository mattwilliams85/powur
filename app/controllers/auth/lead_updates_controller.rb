module Auth
  class LeadUpdatesController < AuthController
    before_action :fetch_lead, only: [ :show ]

    def show
      @lead_update = @lead.last_update

      render 'show'
    end

    private

    # TODO: secure
    def fetch_lead
      @lead = Lead.find(params[:user_quote_id].to_i)
    end
  end
end

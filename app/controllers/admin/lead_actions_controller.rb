module Admin
  class LeadActionsController < AdminController

    def index
      @actions = LeadAction.all
    end

    def show
      @lead_action = LeadAction.find(params[:id])
    end

    def update
      @lead_action = LeadAction.find(params[:id])

      @lead_action.update_attributes!(input)

      render 'index'
    end

    private

    def input
      allow_input(:completion_chance, :action_copy)
    end
  end
end
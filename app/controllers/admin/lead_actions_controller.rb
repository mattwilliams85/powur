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

    def create
      @lead_action = LeadAction.create!(input)

      render 'index'
    end

    def destroy
      @lead_action = LeadAction.find(params[:id])

      @lead_action.destroy!
      @actions = LeadAction.all

      render 'index'
    end

    private

    def input
      allow_input(:completion_chance, :action_copy, :sales_status, :data_status, :opportunity_stage, :lead_status)
    end
  end
end
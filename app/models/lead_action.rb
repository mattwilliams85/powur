class LeadAction < ActiveRecord::Base

  enum data_status: [
    :incomplete, :ready_to_submit,
    :ineligible_location, :submitted ]
  enum sales_status: [
    :in_progress, :proposal, :closed_won, :contract, :installed,
    :duplicate, :ineligible, :closed_lost]
    
  def stage_name 
    return lead_status if lead_status
    return opportunity_stage if opportunity_stage
    return data_status if data_status
    return sales_status if sales_status
  end
end

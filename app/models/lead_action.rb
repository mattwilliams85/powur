class LeadAction < ActiveRecord::Base
  validates :action_copy, presence: true
  validates :data_status, presence: true, unless: 'opportunity_stage.present? || sales_status.present? || lead_status'
  validates :sales_status, presence: true, unless: 'opportunity_stage.present? || data_status.present? || lead_status'
  validates :opportunity_stage, presence: true, unless: 'sales_status.present? || data_status.present? || lead_status'
  validates :lead_status, presence: true, unless: 'sales_status.present? || data_status.present? || opportunity_stage'
  validates :data_status, uniqueness: true, unless: 'sales_status.present? || opportunity_stage || lead_status.present?'
  validates :sales_status, uniqueness: { scope: [:lead_status, :opportunity_stage] }, unless: 'data_status.present?'


  enum data_status: [
    :incomplete, :ready_to_submit,
    :ineligible_location, :submitted ]
  enum sales_status: [
    :in_progress, :proposal, :closed_won, :contract, :installed,
    :duplicate, :ineligible, :closed_lost]
    
  def stage_name
    name = []
    name << lead_status if lead_status
    name << opportunity_stage if opportunity_stage
    name << data_status if data_status
    name << sales_status if sales_status
    return name
  end
end

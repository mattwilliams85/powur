class LeadUpdate < ActiveRecord::Base
  extend LeadUpdateCSV

  belongs_to :quote

  DUPE_STATUS = %w(duplicate)
  OPPORTUNITY_WON_STAGES = [ 'Closed Won' ]
  LOST_STATUS = %w(closed_lost disqualified out_of_service_area)

  def to_h
    { leadUpdateId: id, providerUid: provider_uid }
  end

  def on_hold?
    DUPE_STATUS.include?(status)
  end

  def closed_won?
    contract?
  end

  def lost?
    LOST_STATUS.include?(status)
  end

  def quote_status
    return :on_hold if DUPE_STATUS.include?(status)
    return :closed_won if contract?
    return :lost if LOST_STATUS.include?(status)
    :in_progress
  end
end

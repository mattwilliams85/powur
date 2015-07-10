class LeadUpdate < ActiveRecord::Base
  extend LeadUpdateCSV

  belongs_to :quote

  scope :sales, lambda { |user_id| 
    joins(:quote)
    .where(quotes: {user_id: user_id})
    .where('lead_updates.contract IS NOT NULL')
    .select('DISTINCT ON (lead_updates.quote_id) *')
  }
  scope :within_date_range, lambda { |begin_date, end_date|
    where('quotes.created_at between ? and ?', begin_date, end_date)
  }


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

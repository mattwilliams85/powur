class LeadUpdate < ActiveRecord::Base
  extend LeadUpdateCSV

  belongs_to :lead

  # TODO: deprecate
  scope :within_date_range, lambda { |begin_date, end_date|
    where('quotes.created_at between ? and ?', begin_date, end_date)
  }

  DUPE_STATUS = %w(duplicate)
  INELIGIBLE_STATUS = %w(disqualified out_of_service_area)
  LOST_STATUS = %w(closed_lost)

  def to_h
    { leadUpdateId: id, providerUid: provider_uid }
  end

  def sales_status
    return :duplicate if DUPE_STATUS.include?(status)
    return :ineligible if INELIGIBLE_STATUS.include?(status)
    return :closed_lost if LOST_STATUS.include?(status)
    return :installed if installation?
    return :contract if contract?
    return :proposal if converted?
    :in_progress
  end
end

class LeadUpdate < ActiveRecord::Base
  belongs_to :quote

  def to_h
    { leadUpdateId: id, providerUid: provider_uid }
  end
end

class QuoteFieldLookup < ActiveRecord::Base
  belongs_to :quote_field

  validates_presence_of :quote_field_id, :value
end

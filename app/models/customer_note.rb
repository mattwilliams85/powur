class CustomerNote < ActiveRecord::Base
  belongs_to :customer
  belongs_to :author

  validates_presence_of :customer_id, :author_id, :note
end

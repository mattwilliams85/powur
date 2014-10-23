class Distribution < ActiveRecord::Base
  validates_presence_of :pay_period_id, :user_id, :amount
end

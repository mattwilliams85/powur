class OrderTotal < ActiveRecord::Base

  belongs_to :pay_period
  belongs_to :user
  belongs_to :product

  class << self
  end

end

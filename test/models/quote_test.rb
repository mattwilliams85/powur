require 'test_helper'
 
class UserTest < ActiveSupport::TestCase

  [ :submitted, :closed_won, :open, :lost ].each do |status|
    it "calculates #{status} status" do
      quote = quotes(status)
      quote.calculate_status.must_equal status
    end
  end

end

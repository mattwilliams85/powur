require 'test_helper'
 
class UserTest < ActiveSupport::TestCase

  [ :submitted, :closed_won, :in_progress, :lost, :on_hold ].each do |status|
    it "calculates #{status} status" do
      quote = quotes(status)
      quote.calculate_status.must_equal status
    end
  end

end

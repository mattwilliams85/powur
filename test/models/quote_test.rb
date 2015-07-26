require 'test_helper'
 
class UserTest < ActiveSupport::TestCase
  def test_ready_to_submit_status
    quote = quotes(:incomplete)
    quote.status.must_equal 'incomplete'

    quote.customer.phone = '310.922.2629'
    VCR.use_cassette('zip_validation/valid') do
      quote.input!.must_equal true
    end
    quote.status.must_equal 'ready_to_submit'
  end

  def test_bad_zip_ineligible_location
    quote = quotes(:incomplete)

    quote.customer.phone = '310.922.2629'
    quote.customer.zip = '00000'
    VCR.use_cassette('zip_validation/invalid') do
      quote.input!.must_equal true
    end
    quote.status.must_equal 'ineligible_location'
  end

  def test_incomplete_status
    quote = quotes(:ready_to_submit)
    quote.status.must_equal 'ready_to_submit'

    quote.customer.phone = nil
    quote.input!.must_equal true
    quote.status.must_equal 'incomplete'
  end

  def test_update_received
    quote = quotes(:submitted_new_update)
    last_update = quote.last_update

    quote.update_received.must_equal true
    quote.status.must_equal 'in_progress'

    last_update.status = 'closed_lost'
    quote.update_received.must_equal true
    quote.status.must_equal 'lost'

    quote.status = 'in_progress'
    last_update.status = 'duplicate'
    quote.update_received.must_equal true
    quote.status.must_equal 'on_hold'

    quote.status = 'in_progress'
    last_update.status = 'in_progress'
    last_update.contract = 1.day.ago
    quote.update_received.must_equal true
    quote.status.must_equal 'closed_won'
  end
end

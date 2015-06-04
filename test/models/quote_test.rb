require 'test_helper'
 
class UserTest < ActiveSupport::TestCase
  test 'changing status to ready_to_submit when complete' do
    quote = quotes(:incomplete)
    quote.status.must_equal 'incomplete'

    quote.customer.phone = '310.922.2629'
    quote.input!.must_equal true
    quote.status.must_equal 'ready_to_submit'
  end

  test 'changing status to ineligible_location if unknown zip' do
    quote = quotes(:incomplete)

    quote.customer.phone = '310.922.2629'
    quote.customer.zip = '12121'
    quote.input!.must_equal true
    quote.status.must_equal 'ineligible_location'
  end

  test 'changing status to incomplete when appropriate' do
    quote = quotes(:ready_to_submit)
    quote.status.must_equal 'ready_to_submit'

    quote.customer.phone = nil
    quote.input!.must_equal true
    quote.status.must_equal 'incomplete'
  end
end

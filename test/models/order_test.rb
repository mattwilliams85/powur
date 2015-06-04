require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  def assert_search_result(result)
    expected = [ orders(:search_hit1).id, orders(:search_hit2).id ].sort
    result.must_equal expected
  end

  test 'user searching' do
    result = Order.user_search('gary').map(&:id).sort
    assert_search_result(result)
  end

  test 'customer searching' do
    result = Order.customer_search('gary').map(&:id).sort
    assert_search_result(result)
  end

end

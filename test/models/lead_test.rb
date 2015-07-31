require 'test_helper'
 
class LeadTest < ActiveSupport::TestCase
  def test_ready_to_submit_status
    lead = leads(:incomplete)
    lead.data_status.must_equal 'incomplete'

    lead.customer.phone = '310.922.2629'
    VCR.use_cassette('zip_validation/valid') do
      lead.validate_data_status.must_equal :ready_to_submit
    end
  end

  def test_bad_zip_ineligible_location
    lead = leads(:incomplete)

    lead.customer.phone = '310.922.2629'
    lead.customer.zip = '00000'
    VCR.use_cassette('zip_validation/invalid') do
      lead.validate_data_status.must_equal :ineligible_location
    end
  end

  def test_incomplete_status
    lead = leads(:ready_to_submit)
    lead.data_status.must_equal 'ready_to_submit'

    lead.customer.phone = nil
    lead.validate_data_status.must_equal :incomplete
  end

  def test_update_received
    lead = leads(:submitted_new_update)
    last_update = lead.last_update

    lead.update_received.must_equal true
    lead.sales_status.must_equal 'in_progress'

    last_update.status = 'closed_lost'
    lead.update_received.must_equal true
    lead.sales_status.must_equal 'closed_lost'

    lead.sales_status = 'in_progress'
    last_update.status = 'duplicate'
    lead.update_received.must_equal true
    lead.sales_status.must_equal 'duplicate'

    lead.sales_status = 'in_progress'
    last_update.status = 'in_progress'
    last_update.contract = 1.day.ago
    lead.update_received.must_equal true
    lead.sales_status.must_equal 'contract'

    lead.sales_status = 'in_progress'
    last_update.installation = 1.day.ago
    lead.update_received.must_equal true
    lead.sales_status.must_equal 'installed'
  end
end


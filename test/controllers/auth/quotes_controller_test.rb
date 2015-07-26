require 'test_helper'

module Auth
  class QuotesControllerTest < ActionController::TestCase
    def test_index
      get :index

      siren.must_be_class(:quotes)
      expected = Quote.where(user_id: users(:advocate).id).count
      siren.must_have_entity_size(expected)
    end

    def test_paging_index
      get :index, limit: 4

      siren.must_have_entity_size(4)
    end

    def test_sorting_index
      get :index, sort: 'customer'

      first = siren.entities.first
      last = siren.entities.last

      first.properties.customer_id.must_equal customers(:garey).id
      last.properties.customer_id.must_equal customers(:garry).id
    end

    def test_incomplete_lead_show
      quote = quotes(:incomplete)
      get :show, id: quote.id

      siren.must_be_class(:quote)
      siren.props_must_equal(id: quote.id)
      siren.must_have_actions(:update, :delete, :resend)
      siren.wont_have_actions(:submit)
    end

    def test_ready_to_submit_lead_show
      get :show, id: quotes(:ready_to_submit).id

      siren.must_have_action(:submit)
    end

    def test_in_progress_lead_show
      get :show, id: quotes(:in_progress).id

      siren.wont_have_actions(:update, :delete, :submit)
      lead_update = siren.entity('quote-update')
      lead_update.props_must_equal(status: 'working_lead')
    end

    def test_submitted_lead_show
      get :show, id: quotes(:submitted).id

      siren.wont_have_action(:delete)
    end

    def test_quote_not_owned_show
      get :show, id: quotes(:on_hold)

      siren.must_be_error
    end

    let(:input) do
      { email:      'newcustomer@example.org',
        first_name: 'Big',
        last_name:  'Money',
        city:       'SunnyVille',
        address:    '1212 Cherry Lane',
        state:      'FL',
        phone:      '310.555.1212',
        zip:        '90210' }
    end

    def test_create
      VCR.use_cassette('zip_validation/valid') do
        post :create, input
      end

      siren.must_be_class(:quote)
      siren.props_must_equal(status: 'ready_to_submit')
    end

    def test_update
      quote = quotes(:incomplete)
      VCR.use_cassette('zip_validation/valid') do
        patch :update, id: quote.id, phone: input[:phone]
      end

      siren.props_must_equal(phone: input[:phone])
      siren.props_must_equal(status: 'ready_to_submit')
    end

    def test_delete
      quote = quotes(:incomplete)
      delete :destroy, id: quote.id

      response.status.must_equal 204
    end

    def test_delete_unowned_lead
      delete :destroy, id: quotes(:unowned).id

      siren.must_be_error
      response.status.must_equal 404
    end

    def test_submit_lead
      quote = quotes(:ready_to_submit)

      VCR.use_cassette('quotes/success') do
        post :submit, id: quote.id
      end

      siren.properties.provider_uid.wont_be_nil
      siren.props_must_equal(status: 'submitted')
    end

    # TODO: tests for resend and submit

    class AdminTest < ActionController::TestCase
      def setup
        super(:admin)
      end

      def test_index
        get :index

        siren.must_be_class(:quotes)
        siren.must_have_entity_size(Quote.count)
      end

      def test_index_for_any_user
        get :index, user_id: users(:advocate).id

        expected = Quote.where(user_id: users(:advocate).id).count
        siren.must_have_entity_size(expected)
      end

      def test_index_with_status_filter
        get :index, status: 'closed_won'

        expected = Quote.closed_won.count
        siren.must_have_entity_size(expected)
      end

      def test_index_with_search
        get :index, search: 'gary'

        expected = [ quotes(:search_hit1).id, quotes(:search_hit2).id ].sort
        siren.must_have_entity_size(expected.size)
        siren.entities.map { |e| e.properties.id }.sort.must_equal expected
      end

      def test_deleting_already_submitted_lead
        delete :destroy, id: quotes(:on_hold).id

        siren.must_be_error
      end
    end
  end
end

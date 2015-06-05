require 'test_helper'

module Auth
  class QuotesControllerTest < ActionController::TestCase
    test 'index' do
      get :index

      siren.must_be_class(:quotes)
      expected = Quote.where(user_id: users(:advocate).id).count
      siren.must_have_entity_size(expected)
    end

    test 'index with paging' do
      get :index, limit: 4

      siren.must_have_entity_size(4)
    end

    test 'index with sorting' do
      get :index, sort: 'customer'

      first = siren.entities.first
      last = siren.entities.last

      first.properties.customer_id.must_equal customers(:garey).id
      last.properties.customer_id.must_equal customers(:garry).id
    end

    test 'show incomplete lead' do
      quote = quotes(:incomplete)
      get :show, id: quote.id

      siren.must_be_class(:quote)
      siren.props_must_equal(id: quote.id)
      siren.must_have_actions(:update, :delete, :resend)
      siren.wont_have_actions(:submit)
    end

    test 'show submitted lead' do
      get :show, id: quotes(:in_progress).id

      siren.wont_have_actions(:update, :delete, :submit, :resend)
      lead_update = siren.entity('quote-update')
      lead_update.props_must_equal(status: 'working_lead')
    end

    test 'showing a submitted quote' do
      get :show, id: quotes(:submitted).id

      siren.wont_have_action(:delete)
    end

    test 'show a quote not owned by user' do
      get :show, id: quotes(:on_hold)

      siren.must_be_error
    end

    let(:input) do
      { email:      'newcustomer@example.org',
        first_name: 'Big',
        last_name:  'Money',
        city:       'SunnyVille',
        state:      'FL',
        zip:        zipcodes(:eligible).zip,
        phone:      '310.555.1212' }
    end

    test 'create' do
      post :create, input

      siren.must_be_class(:quote)
      siren.props_must_equal(status: 'ready_to_submit')
    end

    test 'update' do
      quote = quotes(:incomplete)
      patch :update, id: quote.id, phone: input[:phone]

      siren.props_must_equal(phone: input[:phone])
      siren.props_must_equal(status: 'ready_to_submit')
    end

    test 'destroy' do
      quote = quotes(:incomplete)
      delete :destroy, id: quote.id

      response.status.must_equal 204
    end

    test 'destroy quote not belonging to user' do
      delete :destroy, id: quotes(:unowned).id

      siren.must_be_error
      response.status.must_equal 404
    end

    test 'submit' do
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

      test 'index' do
        get :index

        siren.must_be_class(:quotes)
        siren.must_have_entity_size(Quote.count)
      end

      test 'index for any user' do
        get :index, user_id: users(:advocate).id

        expected = Quote.where(user_id: users(:advocate).id).count
        siren.must_have_entity_size(expected)
      end

      test 'index with status filter' do
        get :index, status: 'closed_won'

        expected = Quote.closed_won.count
        siren.must_have_entity_size(expected)
      end

      test 'index with search' do
        get :index, search: 'gary'

        expected = [ quotes(:search_hit1).id, quotes(:search_hit2).id ].sort
        siren.must_have_entity_size(expected.size)
        siren.entities.map { |e| e.properties.id }.sort.must_equal expected
      end

      test 'deleting previously submitted' do
        delete :destroy, id: quotes(:on_hold).id

        siren.must_be_error
      end
    end
  end
end

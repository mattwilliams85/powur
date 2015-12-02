require 'test_helper'

module Auth
  class LeadsControllerTest < ActionController::TestCase
    def test_index
      get :index

      siren.must_be_class(:leads)
      expected = Lead.where(user_id: users(:advocate).id).count
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

      first.properties.first_name.must_equal 'Garey'
      last.properties.first_name.must_equal 'Garry'
    end

    def test_incomplete_lead_show
      lead = leads(:incomplete)
      get :show, id: lead.id

      siren.must_be_class(:lead)
      siren.props_must_equal(id: lead.id)
      siren.must_have_actions(:update, :delete, :resend, :submit)
    end

    def test_ready_to_submit_lead_show
      get :show, id: leads(:ready_to_submit).id

      siren.must_have_action(:submit)
    end

    def test_submitted_lead_show
      get :show, id: leads(:submitted_new_update).id

      siren.wont_have_actions(:update, :delete, :submit)
      lead_update = siren.entity('lead-update')
      lead_update.props_must_equal(status: 'in_progress')
    end

    def test_lead_not_owned_show
      get :show, id: leads(:unowned).id

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
        Lead.stub_any_instance(:valid_phone?, true) do
          post :create, input
        end
      end

      siren.must_be_class(:lead)
      siren.props_must_equal(data_status: 'ready_to_submit')
    end

    def test_update
      lead = leads(:incomplete)
      VCR.use_cassette('zip_validation/valid') do
        patch :update, id: lead.id, phone: input[:phone]
      end

      siren.props_must_equal(phone: input[:phone])
      siren.props_must_equal(data_status: 'ready_to_submit')
    end

    def test_delete
      delete :destroy, id: leads(:incomplete).id

      response.status.must_equal 204
    end

    def test_delete_unowned_lead
      delete :destroy, id: leads(:unowned).id

      siren.must_be_error
      response.status.must_equal 404
    end

    def test_submit_lead
      lead = leads(:ready_to_submit)

      VCR.use_cassette('quotes/success') do
        post :submit, id: lead.id
      end

      siren.properties.provider_uid.wont_be_nil
      siren.props_must_equal(data_status: 'submitted')
    end

  #   # TODO: tests for resend and submit

    class AdminTest < ActionController::TestCase
      def setup
        super(:admin)
      end

      def test_index
        get :index

        siren.must_be_class(:leads)
        siren.must_have_entity_size(Lead.count)
      end

      def test_index_for_any_user
        get :index, user_id: users(:advocate).id

        expected = Lead.where(user_id: users(:advocate).id).count
        siren.must_have_entity_size(expected)
      end

      def test_index_with_status_filter
        get :index, submitted_status: :submitted

        expected = Lead.submitted.count
        siren.must_have_entity_size(expected)

        get :index, submitted_status: :not_submitted
        expected = Lead.not_submitted.count
        siren.must_have_entity_size(expected)

        get :index, submitted_status: :not_submitted,
                    data_status: :ready_to_submit
        expected = Lead.ready_to_submit.count
        siren.must_have_entity_size(expected)
      end

      def test_index_with_search
        get :index, search: 'gary'

        expected = [ leads(:search_hit1).id, leads(:search_hit2).id ].sort
        siren.must_have_entity_size(expected.size)
        siren.entities.map { |e| e.properties.id }.sort.must_equal expected
      end

      def test_deleting_already_submitted_lead
        delete :destroy, id: leads(:submitted).id

        siren.must_be_error
      end
    end
  end
end

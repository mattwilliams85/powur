require 'test_helper'

class Auth::PayPeriodsControllerTest < ActionController::TestCase
  def test_index
    get :index

    siren.must_be_class(:pay_periods)
  end

  class AdminTest < ActionController::TestCase
    def setup
      super(:admin)
    end

    def test_index
      get :index

      siren.must_be_class(:pay_periods)
    end

    def test_index_with_weekly
      get :index, time_span: :weekly

      siren.entities.first.props_must_equal(type: 'Weekly')
    end

    def test_index_weekly_filter
      get :index, time_span: :weekly

      siren.entities.each do |pp|
        pp.props_must_equal(type: 'Weekly')
      end
    end

    def test_show
      get :show, id: pay_periods(:april).id

      siren.must_be_class(:pay_period)
      siren.properties.total_bonus.to_f.must_be :>, 0.0
    end

    def test_calculate
      post :calculate, id: pay_periods(:april).id

      siren.props_must_equal(status: 'queued')
    end
  end
end

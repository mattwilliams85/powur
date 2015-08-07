require 'test_helper'

class Auth::PayPeriodsControllerTest < ActionController::TestCase
  def test_index
    # get :index

    # siren.must_be_class(:pay_periods)
  end


  class AdminTest < ActionController::TestCase
    def test_index
      get :index

      siren.must_be_class(:pay_periods)
    end

    def test_index_weekly_filter
      get :index, time_span: :weekly

      siren.entities.each do |pp|
        pp.must_have_props(type: 'Weekly')
      end
    end

    def test_show
      get :show, id: pay_periods(:april).id

      siren.must_be_class(:pay_period)
    end
  end
end

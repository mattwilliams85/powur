require 'spec_helper'

RSpec.describe Auth::UserActivitiesController, type: :controller do

  render_views

  describe 'GET index' do

    it 'assigns all user_activities as @user_activities' do
      # user_activity login event is created during authentication
      user = create(:user)
      login_user
      get :index, user_id: user.id
      expect(assigns(:user_activities)).to eq(user.user_activities)
    end

  end
end

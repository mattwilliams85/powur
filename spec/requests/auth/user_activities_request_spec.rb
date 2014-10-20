require 'spec_helper'

  describe '/u/users/:id/user_ativities' do

  describe 'GET' do

    it 'does not include a create action' do
      user = create(:user)

      login_user
      puts "LOGIN"
      get user_user_activities_path(user), format: :json
      expect(json_body['actions']).to be_nil
    end
  end

  it 'returns a list of user_activities for the user' do
    user = create(:user)
    create(:user_activity, user_id: user.id)
    create(:user_activity, user_id: user.id)

    login_user

    # get user_activites_path(user_activity.user_id), format: :json
    get user_user_activities_path(user), format: :json
    expect_entities_count(2)
  end


end

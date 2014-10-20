require 'spec_helper'

describe UserActivity, type: :model do

  it 'creates a user_activity' do
    user = create(:user)
    activity = create(:user_activity,
                      user_id: user.id,
                      event: 'login', event_time: DateTime.current)

    expect(activity).to be_instance_of(UserActivity)
  end

  it 'creates a user_activity record witht the current time.' do
    user = create(:user)
    activity = create(:user_activity,
                      user_id: user.id,
                      event: 'login', event_time: DateTime.current)
    login_events = user.user_activities.where(event: 'login').first
    expect(login_events).to be_instance_of(UserActivity)
  end

  it 'returns a list of user_activities for a given pay period' do
    user = create(:user)
    pay_period = create(:monthly_pay_period, at: DateTime.current)
    create(:user_activity,
           user_id:   user.id, event: 'login', event_time: DateTime.current)
    create(:user_activity,
           user_id:    user.id,
           event:      'login',
           event_time: DateTime.current - 1.week)
    create(:user_activity,
           user_id:    user.id,
           event:      'login',
           event_time: DateTime.current - 2.month)

    activities = UserActivity.for_user_by_pay_period(pay_period, user)
    expect(activities.size).to eq(2)
  end
end

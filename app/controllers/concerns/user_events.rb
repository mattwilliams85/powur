module UserEvents
  extend ActiveSupport::Concern

  def track_login_event(user)
    UserActivity.create(user_id:    user.id,
                        event:      'login',
                        event_time: DateTime.current)
  end
end

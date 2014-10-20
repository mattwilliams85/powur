FactoryGirl.define do
  factory :user_activity do
    user
    event 'login'
    event_time DateTime.now
  end
end

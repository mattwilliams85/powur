FactoryGirl.define do
  factory :notification do
    user_id 1
    content 'Hello'
  end

  factory :notification_release do
    user_id 1
    notification_id 1
    recipient 'advocates'
  end
end

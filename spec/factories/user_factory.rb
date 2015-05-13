FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test+#{n}@test.com" }
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    contact('phone' => '858.555.1212', 'zip' => '92127')
    password 'password'
    password_confirmation 'password'
    sequence(:url_slug) { |n| "#{first_name.downcase}_#{n}" }
    roles [ 'admin' ]
    avatar_file_name 'avatar.png'
    last_sign_in_at Time.now.utc
    tos true

    factory :search_miss_user do
      first_name 'xxx'
      last_name 'xxx'
    end
  end
end

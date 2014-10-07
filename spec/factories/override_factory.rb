FactoryGirl.define do

  factory :override, class: 'UserOverride' do
    user
    kind 1
    start_date DateTime.current - 1.month
    end_date DateTime.current + 3.months
  end

end

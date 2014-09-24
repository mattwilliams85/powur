FactoryGirl.define do
  factory :pay_period do

    ignore do
      at DateTime.current - 1.month
    end
    
    factory :monthly_pay_period, class: 'MonthlyPayPeriod' do
      start_date { at.beginning_of_month.to_date }
      type 'MonthlyPayPeriod'
    end

    factory :weekly_pay_period, class: 'WeeklyPayPeriod' do
      start_date { at.beginning_of_week.to_date }
      type 'WeeklyPayPeriod'
    end

  end
end

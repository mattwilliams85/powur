FactoryGirl.define do
  factory :qualification do

    factory :sales_qualification, class: SalesQualification do
      type      'SalesQualification'
      period    Time.now.to_i % 2 + 1
      quantity  { Faker::Number.number(1).to_i }
      product
  
      factory :group_sales_qualification, class: GroupSalesQualification do
        type            'GroupSalesQualification'
        max_leg_percent { Faker::Number.number(2).to_i }
      end
    end

  end
end
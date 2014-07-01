FactoryGirl.define do
  factory :qualification do

    factory :certification_qualification do
      type 'CertificationQualification'
      name Faker::Commerce.product_name
    end

    factory :sales_qualification do
      type      'SalesQualification'
      period    Time.now.to_i % 2
      quantity  Faker::Number.number(3).to_i
  
      factory :group_sales_qualification do
        type            'GroupSalesQualification'
        max_leg_percent Faker::Number.number(2).to_i
      end
    end

  end
end
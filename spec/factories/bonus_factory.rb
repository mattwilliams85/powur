FactoryGirl.define do

  factory :bonus_plan do
    name Faker::Commerce.product_name
  end

  factory :bonus do
    # bonus_plan
    name { Faker::Commerce.product_name }
    # product

    factory :seller_bonus, class: SellerBonus do
      meta_data do
        { first_n: 4, first_n_amount: 200.00 }
      end
    end

    factory :ca_bonus, class: CABonus do
    end

    factory :one_time_bonus, class: OneTimeBonus do
    end
  end

  factory :bonus_amount do
    bonus
    level 0
    amounts [ 0.1, 0.2, 0.3, 0.4, 0.5 ]
  end
end

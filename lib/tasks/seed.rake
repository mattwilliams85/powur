namespace :sunstand do
  namespace :seed do

    SOLAR_ITEM_ID = 1
    CERT_ITEM_ID  = 2

    task ranks: :environment do
      Rank.where.not(id: 1).destroy_all
      Rank.first_or_create(id: 1, title: 'Advocate')
      Rank.create!(id: 2, title: 'Consultant')
      3.upto(8).each { |i| Rank.create(id: i, title: "Rank #{i}") }
      puts 'Created Ranks 1 through 8...'
    end

    task products: :environment do
      Product.destroy_all
      quote_fields = %w(utility average_bill rate_schedule square_feet estimated_credit)
      # roof_material roof_age kwh
      Product.create!(
        id:                    SOLAR_ITEM_ID,
        name:                  'SunRun Solar Item',
        bonus_volume:          500,
        commission_percentage: 80,
        quote_data:            quote_fields)
      Product.create!(
        id:               CERT_ITEM_ID,
        name:             'SunStand Consultant Certification',
        bonus_volume:     300,
        distributor_only: true)
      puts 'Created Products for solar item and consultant certification'
    end

    task qualifications: [ :ranks, :products ] do
      Qualification.destroy_all

      # default path
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  CERT_ITEM_ID)
      puts 'Created Active Qualifications...'
      # Rank 2
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     2,
                                 quantity:    3)
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  CERT_ITEM_ID,
                                 rank_id:     2)
      # Rank 3
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     3,
                                 quantity:    7)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         3,
                                      quantity:        10,
                                      max_leg_percent: 75)
      # Rank 4
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     4,
                                 quantity:    10)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         4,
                                      quantity:        25,
                                      max_leg_percent: 70)
      # Rank 5
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     5,
                                 quantity:    15)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         5,
                                      quantity:        50,
                                      max_leg_percent: 65)
      # Rank 6
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     6,
                                 quantity:    20)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         6,
                                      quantity:        100,
                                      max_leg_percent: 60)
      # Rank 7
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     7,
                                 quantity:    25)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         7,
                                      quantity:        200,
                                      max_leg_percent: 55)
      # Rank 8
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     8,
                                 quantity:    30)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         8,
                                      quantity:        500,
                                      max_leg_percent: 50)

      # non-subscriber path
      path = 'non-subscriber'
      SalesQualification.create!(time_period: :monthly,
                                 product_id:  SOLAR_ITEM_ID,
                                 path:        path)
      # Rank 2
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     2,
                                 quantity:    20,
                                 path:        path)
      # Rank 3
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     3,
                                 quantity:    25,
                                 path:        path)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         3,
                                      quantity:        15,
                                      max_leg_percent: 75,
                                      path:            path)
      # Rank 4
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     4,
                                 quantity:    30,
                                 path:        path)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         4,
                                      quantity:        35,
                                      max_leg_percent: 70,
                                      path:            path)
      # Rank 5
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     5,
                                 quantity:    35,
                                 path:        path)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         5,
                                      quantity:        65,
                                      max_leg_percent: 65,
                                      path:            path)
      # Rank 6
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     6,
                                 quantity:    40,
                                 path:        path)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         6,
                                      quantity:        125,
                                      max_leg_percent: 60,
                                      path:            path)
      # Rank 7
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     7,
                                 quantity:    45,
                                 path:        path)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         7,
                                      quantity:        250,
                                      max_leg_percent: 55,
                                      path:            path)
      # Rank 8
      SalesQualification.create!(time_period: :lifetime,
                                 product_id:  SOLAR_ITEM_ID,
                                 rank_id:     8,
                                 quantity:    50,
                                 path:        path)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         8,
                                      quantity:        600,
                                      max_leg_percent: 50,
                                      path:            path)

      puts 'Created Rank Qualifications...'
    end

    task bonus_plan: [ :qualifications ] do
      BonusPlan.destroy_all

      BonusPlan.create!(id: 1, name: 'SunStand Compensation Plan',
                        start_year: 2014, start_month: 5)

      # Direct Sales Bonus
      bonus = DirectSalesBonus
        .create!(bonus_plan_id: 1, name: 'Direct Sales',
                 schedule: :weekly, compress: false, use_rank_at: :sale)
      BonusSalesRequirement.create!(bonus: bonus, product_id: SOLAR_ITEM_ID)
      BonusLevel.create!(
        bonus:   bonus,
        amounts: [ 0.375, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50 ])

      # Enroller Bonus
      bonus = EnrollerSalesBonus.create!(
        bonus_plan_id:      1,
        name:               'Enroller',
        schedule:           :monthly,
        max_user_rank_id:   1,
        min_upline_rank_id: 2)
      BonusSalesRequirement.create!(bonus: bonus, product_id: SOLAR_ITEM_ID)
      BonusLevel.create!(
        bonus:   bonus,
        amounts: [ 0.0, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125 ])

      # Differential Bonus
      bonus = DifferentialBonus.create!(
        bonus_plan_id:      1,
        name:               'Differential',
        schedule:           :monthly,
        compress:           true,
        max_user_rank_id:   1,
        min_upline_rank_id: 2)
      BonusSalesRequirement.create!(
        bonus:      bonus,
        product_id: SOLAR_ITEM_ID,
        source:     false)
      BonusSalesRequirement.create!(bonus: bonus, product_id: CERT_ITEM_ID)
      BonusLevel.create!(
        bonus:   bonus,
        amounts: [ 0.0, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60, 0.70 ])

      # Promote Out Bonus
      PromoteOutBonus.create!(
        bonus_plan_id:      1,
        name:               'Promote-Out',
        schedule:           :monthly,
        achieved_rank_id:   2,
        min_upline_rank_id: 2,
        flat_amount:        150)

      # Unilevel Bonus
      bonus = UnilevelSalesBonus.create!(
        bonus_plan_id: 1,
        name:          'Unileveled',
        schedule:      :monthly,
        compress:      true)
      BonusSalesRequirement.create!(bonus: bonus, product_id: SOLAR_ITEM_ID)
      BonusLevel.create!(bonus: bonus, level: 1,
        amounts: [ 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125 ])
      BonusLevel.create!(bonus: bonus, level: 2,
        amounts: [ 0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10 ])
      BonusLevel.create!(bonus: bonus, level: 3,
        amounts: [ 0.075, 0.075, 0.075, 0.075, 0.075, 0.075, 0.075, 0.075 ])
      BonusLevel.create!(bonus: bonus, level: 4,
        amounts: [ 0.00, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05 ])
      BonusLevel.create!(bonus: bonus, level: 5,
        amounts: [ 0.00, 0.00, 0.0375, 0.0375, 0.0375, 0.0375, 0.0375, 0.0375 ])
      BonusLevel.create!(bonus: bonus, level: 6,
        amounts: [ 0.00, 0.00, 0.00, 0.025, 0.025, 0.025, 0.025, 0.025 ])
      BonusLevel.create!(bonus: bonus, level: 7,
        amounts: [ 0.00, 0.00, 0.00, 0.00, 0.025, 0.025, 0.025, 0.025 ])
      BonusLevel.create!(bonus: bonus, level: 8,
        amounts: [ 0.00, 0.00, 0.00, 0.00, 0.00, 0.025, 0.025, 0.025 ])
    end
  end
end

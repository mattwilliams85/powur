namespace :sunstand do
  namespace :seed do

    SOLAR_ITEM_ID = 1
    CERT_ITEM_ID  = 2

    task ranks: :environment do
      Rank.destroy_all
      Rank.create!(id: 1, title: 'Advocate')
      Rank.create!(id: 2, title: 'Consultant')
      3.upto(8).each { |i| Rank.create(id: i, title: "Rank #{i}") }
      puts "Created Ranks 1 through 8..."
    end

    task products: :environment do
      Product.destroy_all
      Product.create!(
        id:                     SOLAR_ITEM_ID,
        name:                   'SunRun Solar Item', 
        bonus_volume:           500,
        commission_percentage:  80,
        quote_data:             %w(utility rate_schedule roof_material roof_age kwh))
      Product.create!(
        id:               CERT_ITEM_ID,
        name:             'SunStand Consultant Certification', 
        bonus_volume:     300,
        distributor_only: true)
      puts "Created Products for solar item and consultant certification"
    end

    task qualifications: [ :ranks, :products ] do
      Qualification.destroy_all
      SalesQualification.create!(time_period: :lifetime, product_id: SOLAR_ITEM_ID)
      puts 'Created Active Qualifications...'
      # Rank 2
      SalesQualification.create!(tiem_period: :lifetime, product_id: SOLAR_ITEM_ID, rank_id: 2, quantity: 3)
      SalesQualification.create!(time_period: :lifetime, product_id: CERT_ITEM_ID, rank_id: 2)
      # Rank 3
      SalesQualification.create!(time_period: :lifetime, product_id: SOLAR_ITEM_ID, rank_id: 3, quantity: 7)
      GroupSalesQualification.create!(time_period: :monthly, product_id: SOLAR_ITEM_ID, rank_id: 3, quantity: 10, max_leg_percent: 75)
      # Rank 4
      SalesQualification.create!(time_period: :lifetime, product_id: SOLAR_ITEM_ID, rank_id: 4, quantity: 10)
      GroupSalesQualification.create!(time_period: :monthly, product_id: SOLAR_ITEM_ID, rank_id: 4, quantity: 25, max_leg_percent: 70)
      # Rank 5
      SalesQualification.create!(time_period: :lifetime, product_id: SOLAR_ITEM_ID, rank_id: 4, quantity: 15)
      GroupSalesQualification.create!(time_period: :monthly, product_id: SOLAR_ITEM_ID, rank_id: 4, quantity: 50, max_leg_percent: 65)
      # Rank 6
      SalesQualification.create!(time_period: :lifetime, product_id: SOLAR_ITEM_ID, rank_id: 4, quantity: 20)
      GroupSalesQualification.create!(time_period: :monthly, product_id: SOLAR_ITEM_ID, rank_id: 4, quantity: 100, max_leg_percent: 60)
      # Rank 7
      SalesQualification.create!(time_period: :lifetime, product_id: SOLAR_ITEM_ID, rank_id: 4, quantity: 25)
      GroupSalesQualification.create!(time_period: :monthly, product_id: SOLAR_ITEM_ID, rank_id: 4, quantity: 200, max_leg_percent: 55)
      # Rank 8
      GroupSalesQualification.create!(time_period: :monthly, product_id: SOLAR_ITEM_ID, rank_id: 4, quantity: 500, max_leg_percent: 50)
      puts 'Created Rank Qualifications...'
    end

    task bonus_plan: [ :qualifications ] do
      BonusPlan.destroy_all

      BonusPlan.create!(id: 1, name: 'SunStand Compensation Plan', start_year: 2014, start_month: 5)

      # Direct Sales Bonus
      bonus = DirectSalesBonus.create!(bonus_plan_id: 1, name: 'Direct Sales',
        schedule: :weekly, compress: false)
      BonusSalesRequirement.create!(bonus: bonus, product_id: SOLAR_ITEM_ID)
      BonusLevel.create!(bonus: bonus, amounts: [ 0.375, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50 ])

      # Enroller Bonus
      bonus = EnrollerSalesBonus.create!(bonus_plan_id: 1, name: 'Enroller',
        schedule: :weekly, max_user_rank_id: 1, min_upline_rank_id: 2)
      BonusSalesRequirement.create!(bonus: bonus, product_id: SOLAR_ITEM_ID)
      BonusLevel.create!(bonus: bonus, amounts: [ 0.0, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125 ])

      # Differential Bonus
      bonus = DifferentialBonus.create!(bonus_plan_id: 1, name: 'Differential',
        schedule: :monthly, compress: true, max_user_rank_id: 1, min_upline_rank_id: 2)
      BonusSalesRequirement.create!(bonus: bonus, product_id: SOLAR_ITEM_ID, source: false)
      BonusSalesRequirement.create!(bonus: bonus, product_id: CERT_ITEM_ID)
      BonusLevel.create!(bonus: bonus, amounts: [ 0.0, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60, 0.70 ])

      # Promote Out Bonus
      bonus = PromoteOutBonus.create!(bonus_plan_id: 1, name: 'Promote-Out',
        schedule: :monthly, achieved_rank_id: 2, min_upline_rank_id: 2)

      # Unilevel Bonus
      bonus = UnilevelSalesBonus.create!(bonus_plan_id: 1, name: 'Unileveled',
        schedule: :monthly, compress: true)
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

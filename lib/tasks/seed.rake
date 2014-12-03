namespace :sunstand do
  namespace :seed do

    SOLAR_ITEM_ID = 1
    CERT_ITEM_ID  = 2

    BASIC_PATH_ID = 1
    PRO_PATH_ID   = 2

    task ranks: :environment do
      Rank.where.not(id: 1).destroy_all
      Rank.first_or_create(id: 1, title: 'Advocate')
      Rank.create!(id: 2, title: 'Consultant')
      3.upto(8).each { |i| Rank.create(id: i, title: "Rank #{i}") }
      puts 'Created Ranks 1 through 8...'
    end

    task sunrun_product: :environment do
      existing = Product.find_by_id(SOLAR_ITEM_ID)
      existing.destroy if existing
      fields = { utility:                :lookup,
                 average_bill:           :number,
                 square_feet:            :number,
                 credit_score_qualified: :boolean,
                 roof_type:              :lookup,
                 roof_age:               :lookup }

      Product.create!(
        id:                    SOLAR_ITEM_ID,
        name:                  'SunRun Solar Item',
        bonus_volume:          500,
        commission_percentage: 80)

      fields.each do |name, data_type|
        QuoteField.create!(
          product_id: SOLAR_ITEM_ID,
          name:       name.to_s,
          data_type:  data_type)
      end
      field = QuoteField.find_by(name: 'average_bill')
      field.update_column(:required, true)
      Rake::Task['sunstand:import:quote_field_lookups'].execute
    end

    task products: :environment do
      Product.destroy_all
      Rake::Task['sunstand:seed:sunrun_product'].execute
      Product.create!(
        id:               CERT_ITEM_ID,
        name:             'SunStand Consultant Certification',
        bonus_volume:     300,
        distributor_only: true)
      puts 'Created Products for solar item and consultant certification'
    end

    task rank_paths: :environment do
      RankPath.destroy_all

      RankPath.create!(id: BASIC_PATH_ID, name: 'Basic')
      RankPath.create!(id: PRO_PATH_ID, name: 'Pro')
    end

    task qualifications: [ :ranks, :products, :rank_paths ] do
      Qualification.destroy_all

      # active qualifications
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   CERT_ITEM_ID,
                                 rank_path_id: PRO_PATH_ID)
      puts 'Created Active Qualifications...'

      # Rank 2
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      2,
                                 quantity:     3,
                                 rank_path_id: PRO_PATH_ID)
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   CERT_ITEM_ID,
                                 rank_id:      2,
                                 rank_path_id: PRO_PATH_ID)

      # Rank 3
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      3,
                                 quantity:     5,
                                 rank_path_id: PRO_PATH_ID)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         3,
                                      quantity:        7,
                                      max_leg_percent: 75,
                                      rank_path_id:    PRO_PATH_ID)

      # Rank 4
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      4,
                                 quantity:     7,
                                 rank_path_id: PRO_PATH_ID)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         4,
                                      quantity:        25,
                                      max_leg_percent: 70,
                                      rank_path_id:    PRO_PATH_ID)
      # Rank 5
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      5,
                                 quantity:     10,
                                 rank_path_id: PRO_PATH_ID)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         5,
                                      quantity:        50,
                                      max_leg_percent: 65,
                                      rank_path_id:    PRO_PATH_ID)
      # Rank 6
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      6,
                                 quantity:     12,
                                 rank_path_id: PRO_PATH_ID)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         6,
                                      quantity:        100,
                                      max_leg_percent: 60,
                                      rank_path_id:    PRO_PATH_ID)
      # Rank 7
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      7,
                                 quantity:     15,
                                 rank_path_id: PRO_PATH_ID)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         7,
                                      quantity:        200,
                                      max_leg_percent: 55,
                                      rank_path_id:    PRO_PATH_ID)
      # Rank 8
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      8,
                                 quantity:     20,
                                 rank_path_id: PRO_PATH_ID)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         8,
                                      quantity:        500,
                                      max_leg_percent: 50,
                                      rank_path_id:    PRO_PATH_ID)

      # active qualifications
      SalesQualification.create!(time_period:  :monthly,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_path_id: BASIC_PATH_ID)
      # Rank 2
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      2,
                                 quantity:     3,
                                 rank_path_id: BASIC_PATH_ID)
      GroupSalesQualification.create!(time_period:  :monthly,
                                      product_id:   SOLAR_ITEM_ID,
                                      rank_id:      2,
                                      quantity:     5,
                                      rank_path_id: BASIC_PATH_ID)

      # Rank 3
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      3,
                                 quantity:     5,
                                 rank_path_id: BASIC_PATH_ID)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         3,
                                      quantity:        7,
                                      max_leg_percent: 75,
                                      rank_path_id:    BASIC_PATH_ID)

      # Rank 4
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      4,
                                 quantity:     7,
                                 rank_path_id: BASIC_PATH_ID)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         4,
                                      quantity:        25,
                                      max_leg_percent: 70,
                                      rank_path_id:    BASIC_PATH_ID)
      # Rank 5
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      5,
                                 quantity:     10,
                                 rank_path_id: BASIC_PATH_ID)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         5,
                                      quantity:        50,
                                      max_leg_percent: 65,
                                      rank_path_id:    BASIC_PATH_ID)
      # Rank 6
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      6,
                                 quantity:     12,
                                 rank_path_id: BASIC_PATH_ID)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         6,
                                      quantity:        100,
                                      max_leg_percent: 60,
                                      rank_path_id:    BASIC_PATH_ID)
      # Rank 7
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      7,
                                 quantity:     15,
                                 rank_path_id: BASIC_PATH_ID)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         7,
                                      quantity:        200,
                                      max_leg_percent: 55,
                                      rank_path_id:    BASIC_PATH_ID)
      # Rank 8
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      8,
                                 quantity:     20,
                                 rank_path_id: BASIC_PATH_ID)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         8,
                                      quantity:        500,
                                      max_leg_percent: 50,
                                      rank_path_id:    BASIC_PATH_ID)


      puts 'Created Rank Qualifications...'
    end

    task bonus_plan: [ :qualifications ] do
      BonusPlan.destroy_all

      BonusPlan.create!(id: 1, name: 'SunStand Compensation Plan',
                        start_year: 2014, start_month: 5)

      # Direct Sales Bonus
      bonus = DirectSalesBonus.create!(
        bonus_plan_id: 1,
        name:          'Direct Sales',
        schedule:      :weekly,
        compress:      false,
        use_rank_at:   :sale)
      BonusSalesRequirement.create!(bonus: bonus, product_id: SOLAR_ITEM_ID)
      BonusLevel.create!(
        bonus:        bonus,
        rank_path_id: BASIC_PATH_ID,
        amounts:      [ 0.25, 0.25, 0.25, 0.25, 0.25, 0.50, 0.50, 0.50 ])
      BonusLevel.create!(
        bonus:        bonus,
        rank_path_id: PRO_PATH_ID,
        amounts:      [ 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50 ])

      # Enroller Bonus
      bonus = EnrollerBonus.create!(
        bonus_plan_id:      1,
        name:               'Enroller',
        schedule:           :monthly,
        max_user_rank_id:   1,
        min_upline_rank_id: 2)
      BonusSalesRequirement.create!(bonus: bonus, product_id: SOLAR_ITEM_ID)
      BonusLevel.create!(
        bonus:   bonus,
        amounts: [ 0.0, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125 ])

      # Unilevel Bonus
      bonus = UnilevelBonus.create!(
        bonus_plan_id: 1,
        name:          'Uni-level',
        schedule:      :monthly,
        compress:      true)
      BonusSalesRequirement.create!(bonus: bonus, product_id: SOLAR_ITEM_ID)
      BonusLevel.create!(bonus: bonus, level: 1, rank_path_id: BASIC_PATH_ID,
                         amounts: Array.new(8, 0.0625))
      BonusLevel.create!(bonus: bonus, level: 1, rank_path_id: PRO_PATH_ID,
                         amounts: Array.new(8, 0.125))

      BonusLevel.create!(bonus: bonus, level: 2, rank_path_id: BASIC_PATH_ID,
                         amounts: Array.new(7, 0.05).unshift(0))
      BonusLevel.create!(bonus: bonus, level: 2, rank_path_id: PRO_PATH_ID,
                         amounts: Array.new(7, 0.10).unshift(0))

      BonusLevel.create!(bonus: bonus, level: 3, rank_path_id: BASIC_PATH_ID,
                         amounts: Array.new(6, 0.075).unshift(0, 0))
      BonusLevel.create!(bonus: bonus, level: 3, rank_path_id: PRO_PATH_ID,
                         amounts: Array.new(6, 0.0375).unshift(0, 0))

      BonusLevel.create!(bonus: bonus, level: 4, rank_path_id: BASIC_PATH_ID,
                         amounts: Array.new(5, 0.05).unshift(0, 0, 0))
      BonusLevel.create!(bonus: bonus, level: 4, rank_path_id: PRO_PATH_ID,
                         amounts: Array.new(5, 0.025).unshift(0, 0, 0))

      BonusLevel.create!(bonus: bonus, level: 5, rank_path_id: BASIC_PATH_ID,
                         amounts: Array.new(4, 0.0175).unshift(0, 0, 0, 0))
      BonusLevel.create!(bonus: bonus, level: 5, rank_path_id: PRO_PATH_ID,
                         amounts: Array.new(4, 0.0375).unshift(0, 0, 0, 0))

      BonusLevel.create!(bonus: bonus, level: 6, rank_path_id: BASIC_PATH_ID,
                         amounts: Array.new(3, 0.0125).unshift(0, 0, 0, 0, 0))
      BonusLevel.create!(bonus: bonus, level: 6, rank_path_id: PRO_PATH_ID,
                         amounts: Array.new(3, 0.025).unshift(0, 0, 0, 0, 0))

      BonusLevel.create!(
        bonus: bonus, level: 7, rank_path_id: BASIC_PATH_ID,
        amounts: Array.new(2, 0.0125).unshift(0, 0, 0, 0, 0, 0))
      BonusLevel.create!(bonus: bonus, level: 7, rank_path_id: PRO_PATH_ID,
                         amounts: Array.new(2, 0.025).unshift(0, 0, 0, 0, 0, 0))

      BonusLevel.create!(
        bonus: bonus, level: 8, rank_path_id: BASIC_PATH_ID,
        amounts: Array.new(2, 0.0125).unshift(0, 0, 0, 0, 0, 0))
      BonusLevel.create!(bonus: bonus, level: 8, rank_path_id: PRO_PATH_ID,
                         amounts: Array.new(2, 0.025).unshift(0, 0, 0, 0, 0, 0))

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
    end
  end
end

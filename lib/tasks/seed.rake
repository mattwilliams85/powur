namespace :powur do
  namespace :seed do

    RANK_TITLES = [
      'Direct Seller', 'Local Grid Leader',
      'Community Grid Leader', 'City Grid Leader',
      'Regional Grid Leader', 'State Grid Leader',
      'National Grid Leader', 'Game Changer ' ]

    SOLAR_ITEM_ID = 1
    CERT_ITEM_ID  = 2
    CERT2_ITEM_ID  = 3
    CERT3_ITEM_ID = 4

    BASIC_PATH_ID = 1
    PRO_PATH_ID   = 2

    SOLAR_PRODUCT_FIELDS = [
      { name:      'average_bill',
        data_type: :number,
        required:  false } ]

    task ranks: :environment do
      Rank.destroy_all
      RANK_TITLES.each { |title| Rank.create!(title: title) }
      puts 'Created Ranks...'
    end

    task solar_product: :environment do
      existing = Product.find_by_id(SOLAR_ITEM_ID)
      existing.destroy if existing

      product = Product.create!(
        id:                    SOLAR_ITEM_ID,
        name:                  'Solar Item',
        bonus_volume:          1000,
        commission_percentage: 80)

      SOLAR_PRODUCT_FIELDS.each do |attrs|
        product.quote_fields.create!(attrs)
      end

      Rake::Task['powur:import:quote_field_lookups'].execute

      puts 'Created Solar Product item...'
    end

    task products: :environment do
      Product.destroy_all
      Rake::Task['powur:seed:solar_product'].execute

      Product.create!(
        id:                  CERT_ITEM_ID,
        name:                'Certified -- Grow your Grid',
        description:         'Powur Certification gives you all the tools you need to build a high performing team and share in the rewards of their success. If you are going to mentor others, you need training. This is your first step. Now you have the power.',
        bonus_volume:        14900,
        distributor_only:    true,
        certifiable:         true,
        image_original_path: 'https://s3.amazonaws.com/sunstand-dev/products/certification.jpg',
        smarteru_module_id:  '8342',
        position:            2)

      Product.create!(
        id:                  CERT2_ITEM_ID,
        name:                'Shine',
        description:         'Taking a bold step into a new industry requires new skills and an entrepreneurial spirit. From the basics of the solar energy industry to transforming yourself into a business leader, Shine gives you the tools you need to hit the ground running.',
        bonus_volume:        0,
        distributor_only:    true,
        certifiable:         true,
        image_original_path: 'https://s3.amazonaws.com/sunstand-dev/products/shine.jpg',
        smarteru_module_id:  '8362',
        position:            3)

      Product.create!(
        id:                  CERT3_ITEM_ID,
        name:                'Fast Impact Training (FIT)',
        description:         'Fast Impact Training',
        bonus_volume:        0,
        distributor_only:    true,
        certifiable:         true,
        image_original_path: 'https://s3.amazonaws.com/sunstand-dev/products/fit.jpg',
        smarteru_module_id:  '8319',
        is_required_class:   true,
        position:            1)

      puts 'Created Products for solar item and consultant certification'
    end

    task qualifications: [ :ranks, :products, :notifications ] do
      Qualification.destroy_all

      # active qualifications
      # SalesQualification.create!(time_period:  :lifetime,
      #                            product_id:   CERT_ITEM_ID)

      # Rank 1
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   CERT_ITEM_ID,
                                 rank_id:      1)
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      2,
                                 quantity:     2)

      # Rank 2
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      2,
                                 quantity:     4)

      # Rank 3
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      3,
                                 quantity:     6)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         3,
                                      quantity:        25,
                                      max_leg_percent: 75)

      # Rank 4
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      4,
                                 quantity:     8)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         4,
                                      quantity:        50,
                                      max_leg_percent: 75)

      # Rank 5
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      5,
                                 quantity:     10)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         5,
                                      quantity:        100,
                                      max_leg_percent: 75)

      # Rank 6
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      6,
                                 quantity:     12)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         6,
                                      quantity:        250,
                                      max_leg_percent: 75)

      # Rank 7
      SalesQualification.create!(time_period:  :lifetime,
                                 product_id:   SOLAR_ITEM_ID,
                                 rank_id:      7,
                                 quantity:     14)
      GroupSalesQualification.create!(time_period:     :monthly,
                                      product_id:      SOLAR_ITEM_ID,
                                      rank_id:         7,
                                      quantity:        500,
                                      max_leg_percent: 75)

      puts 'Created Rank Qualifications...'
    end

    task bonus_plan: [ :qualifications ] do
      BonusPlan.destroy_all

      BonusPlan.create!(id: 1, name: 'Powur Compensation Plan',
                        start_year: 2015, start_month: 2)

      # # Direct Sales Bonus
      # bonus = DirectSalesBonus.create!(
      #   bonus_plan_id: 1,
      #   name:          'Direct Sales',
      #   schedule:      :weekly,
      #   compress:      false,
      #   use_rank_at:   :sale)
      # BonusSalesRequirement.create!(bonus: bonus, product_id: SOLAR_ITEM_ID)
      # BonusLevel.create!(
      #   bonus:        bonus,
      #   rank_path_id: BASIC_PATH_ID,
      #   amounts:      [ 0.25, 0.25, 0.25, 0.25, 0.25, 0.50, 0.50, 0.50 ])
      # BonusLevel.create!(
      #   bonus:        bonus,
      #   rank_path_id: PRO_PATH_ID,
      #   amounts:      [ 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50 ])

      # # Enroller Bonus
      # bonus = EnrollerBonus.create!(
      #   bonus_plan_id:      1,
      #   name:               'Enroller',
      #   schedule:           :monthly)
      # BonusSalesRequirement.create!(bonus: bonus, product_id: SOLAR_ITEM_ID)
      # BonusLevel.create!(
      #   bonus:   bonus,
      #   amounts: [ 0.0, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125 ])

      # # Unilevel Bonus
      # bonus = UnilevelBonus.create!(
      #   bonus_plan_id: 1,
      #   name:          'Uni-level',
      #   schedule:      :monthly,
      #   compress:      true)
      # BonusSalesRequirement.create!(bonus: bonus, product_id: SOLAR_ITEM_ID)
      # BonusLevel.create!(bonus: bonus, level: 1, rank_path_id: BASIC_PATH_ID,
      #                    amounts: Array.new(8, 0.0625))
      # BonusLevel.create!(bonus: bonus, level: 1, rank_path_id: PRO_PATH_ID,
      #                    amounts: Array.new(8, 0.125))

      # BonusLevel.create!(bonus: bonus, level: 2, rank_path_id: BASIC_PATH_ID,
      #                    amounts: Array.new(7, 0.05).unshift(0))
      # BonusLevel.create!(bonus: bonus, level: 2, rank_path_id: PRO_PATH_ID,
      #                    amounts: Array.new(7, 0.10).unshift(0))

      # BonusLevel.create!(bonus: bonus, level: 3, rank_path_id: BASIC_PATH_ID,
      #                    amounts: Array.new(6, 0.075).unshift(0, 0))
      # BonusLevel.create!(bonus: bonus, level: 3, rank_path_id: PRO_PATH_ID,
      #                    amounts: Array.new(6, 0.0375).unshift(0, 0))

      # BonusLevel.create!(bonus: bonus, level: 4, rank_path_id: BASIC_PATH_ID,
      #                    amounts: Array.new(5, 0.05).unshift(0, 0, 0))
      # BonusLevel.create!(bonus: bonus, level: 4, rank_path_id: PRO_PATH_ID,
      #                    amounts: Array.new(5, 0.025).unshift(0, 0, 0))

      # BonusLevel.create!(bonus: bonus, level: 5, rank_path_id: BASIC_PATH_ID,
      #                    amounts: Array.new(4, 0.0175).unshift(0, 0, 0, 0))
      # BonusLevel.create!(bonus: bonus, level: 5, rank_path_id: PRO_PATH_ID,
      #                    amounts: Array.new(4, 0.0375).unshift(0, 0, 0, 0))

      # BonusLevel.create!(bonus: bonus, level: 6, rank_path_id: BASIC_PATH_ID,
      #                    amounts: Array.new(3, 0.0125).unshift(0, 0, 0, 0, 0))
      # BonusLevel.create!(bonus: bonus, level: 6, rank_path_id: PRO_PATH_ID,
      #                    amounts: Array.new(3, 0.025).unshift(0, 0, 0, 0, 0))

      # BonusLevel.create!(
      #   bonus: bonus, level: 7, rank_path_id: BASIC_PATH_ID,
      #   amounts: Array.new(2, 0.0125).unshift(0, 0, 0, 0, 0, 0))
      # BonusLevel.create!(bonus: bonus, level: 7, rank_path_id: PRO_PATH_ID,
      #                    amounts: Array.new(2, 0.025).unshift(0, 0, 0, 0, 0, 0))

      # BonusLevel.create!(
      #   bonus: bonus, level: 8, rank_path_id: BASIC_PATH_ID,
      #   amounts: Array.new(2, 0.0125).unshift(0, 0, 0, 0, 0, 0))
      # BonusLevel.create!(bonus: bonus, level: 8, rank_path_id: PRO_PATH_ID,
      #                    amounts: Array.new(2, 0.025).unshift(0, 0, 0, 0, 0, 0))

      # # Fast-Start Bonus
      # bonus = FastStartBonus.create!(
      #   bonus_plan_id:      1,
      #   name:               'Fast-Start',
      #   schedule:           :monthly,
      #   time_period:        'months',
      #   time_amount:        1)
      # # BonusSalesRequirement.create!(bonus:      bonus,
      # #                               product_id: SOLAR_ITEM_ID,
      # #                               quantity:   3)
      # # BonusLevel.create!(
      # #   bonus:   bonus,
      # #   amounts: [ 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 ])

      # # Differential Bonus
      # bonus = DifferentialBonus.create!(
      #   bonus_plan_id:      1,
      #   name:               'Differential',
      #   schedule:           :monthly,
      #   compress:           true,
      #   max_user_rank_id:   1,
      #   min_upline_rank_id: 2)
      # BonusSalesRequirement.create!(
      #   bonus:      bonus,
      #   product_id: SOLAR_ITEM_ID,
      #   source:     false)
      # BonusSalesRequirement.create!(bonus: bonus, product_id: CERT_ITEM_ID)
      # BonusLevel.create!(
      #   bonus:   bonus,
      #   amounts: [ 0.0, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60, 0.70 ])

      # # Promote Out Bonus
      # PromoteOutBonus.create!(
      #   bonus_plan_id:      1,
      #   name:               'Promote-Out',
      #   schedule:           :monthly,
      #   min_upline_rank_id: 2,
      #   flat_amount:        150)
    end

    task notifications: :environment do
      Notification.destroy_all

      Notification.create!(
        content: 'These messages are part of the Powur notification system. Administrators can use the Administrator dashboard to add and remove notifications.')
      Notification.create!(
        content: 'The future of the planet is in our hands. <a href="http://powur.com">')
      Notification.create!(
        content: 'Did you know that on one single day, the sun sends 15,000 times as much energy to the Earth as we consume worldwide on a daily basis?')
      Notification.create!(
        content: 'Solar power is the energy of the future — safe, clean, and 100% environmentally compatible.')

      puts 'Seeded Sample Dashboard Notifications'
    end
  end
end

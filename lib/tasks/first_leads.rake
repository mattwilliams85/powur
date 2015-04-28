namespace :powur do
  namespace :first_leads do

    ROOT_ADVOCATE_ID = 42

    ROOT_ADVOCATE = {
      id:         ROOT_ADVOCATE_ID,
      email:      'thejonathanbudd@gmail.com',
      first_name: 'Jonathan',
      last_name:  'Budd' }

    AARON = {
      sponsor_id: ROOT_ADVOCATE_ID,
      id:         50,
      email:      'info@aaronfortner.com',
      first_name: 'Aaron',
      last_name:  'Fortner' }
    GREGORY = {
      sponsor_id: AARON[:id],
      id:         51,
      email:      'gmascari@me.com',
      first_name: 'Gregory',
      last_name:  'Mascari' }
    HAYDON = {
      sponsor_id: GREGORY[:id],
      id:         52,
      email:      'haydoncameron@gmail.com',
      first_name: 'Haydon',
      last_name:  'Cameron' }
    BOB = {
      sponsor_id: HAYDON[:id],
      id:         53,
      email:      'bob@bobdoran.com',
      first_name: 'Bob',
      last_name:  'Doran',
      address:    '1001 Michael Lane',
      city:       'Eagleville',
      state:      'PA',
      zip:        '19403',
      phone:      '(610) 283-6113' }
    JAKE = {
      sponsor_id: ROOT_ADVOCATE_ID,
      id:         60,
      email:      'Jake@JakeDucey.com',
      first_name: 'Jake',
      last_name:  'Ducey' }

    ADVOCATES = [ ROOT_ADVOCATE, AARON, GREGORY, HAYDON, BOB, JAKE ]
    ADVOCATE_IDS = ADVOCATES.map { |a| a[:id] }
    TEMP_PASS = 'solarpower42'

    def destroy_user(id)
      User.destroy(id)
    rescue ActiveRecord::RecordNotFound
    end

    task clean_users: :environment do
      ADVOCATE_IDS.reverse.each { |id| destroy_user(id) }
    end

    task users: :environment do
      ADVOCATES.each do |attrs|
        attrs = attrs.merge(
          password:              TEMP_PASS,
          password_confirmation: TEMP_PASS,
          tos:                   true)

        User.create!(attrs)
      end
    end

    PRODUCT_ID = 1
    LEAD1 = {
      id:       101,
      user_id:  HAYDON[:id],
      customer: {
        email:      'bob@bobdoran.com',
        first_name: 'Bob',
        last_name:  'Doran',
        address:    '1001 Michael Lane',
        city:       'Eagleville',
        state:      'PA',
        zip:        '19403',
        phone:      '(610) 283-6113' } }
    LEAD2 = {
      id:       102,
      user_id:  BOB[:id],
      customer: {
        email:      'andremdery@gmail.com',
        first_name: 'Andre',
        last_name:  'Dery',
        address:    '980 Churchville Rd',
        city:       'Fairfield',
        state:      'CT',
        zip:        '06825',
        phone:      '(203) 520-7232' } }
    LEAD3 = {
      id:       103,
      user_id:  BOB[:id],
      customer: {
        email:      'victorgirardi@gmail.com',
        first_name: 'Victor',
        last_name:  'Girardi',
        address:    '74 Rees Dr',
        city:       'Oxford',
        state:      'CT',
        zip:        '06478',
        phone:      '(203) 395-5118' } }
    LEAD4 = {
      id:       104,
      user_id:  JAKE[:id],
      customer: {
        email:      'sistaralchemy@gmail.com',
        first_name: 'Jennifer',
        last_name:  'Lasek',
        address:    '3255 Fortuna Ranch',
        city:       'Encinitas',
        state:      'CA',
        zip:        '92024',
        phone:      '760 481 4653' } }
    LEAD5 = {
      id:       105,
      user_id:  ROOT_ADVOCATE_ID,
      customer: {
        email:      'stylerfamily@yahoo.com',
        first_name: 'Rick',
        last_name:  'Styler',
        address:    '78725 Villeta Dr',
        city:       'La Quinta',
        state:      'CA',
        zip:        '92253',
        phone:      '760 360 1404' } }

    LEADS = [ LEAD1, LEAD2, LEAD3, LEAD4, LEAD5 ]

    def destroy_quote(id)
      begin
        Quote.destroy(id)
      rescue ActiveRecord::RecordNotFound
      end
      Customer.destroy(id)
    rescue ActiveRecord::RecordNotFound
    end

    task clean_quotes: :environment do
      LEADS.each do |lead|
        destroy_quote(lead[:id])
      end
    end

    task quotes: :environment do
      Product.find_by(id: PRODUCT_ID) || fail('Need to create product first!')
      LEADS.each do |lead|
        customer = Customer.create!(lead[:customer].merge(id: lead[:id]))
        Quote.create!(
          id:         lead[:id],
          product_id: PRODUCT_ID,
          user_id:    lead[:user_id],
          customer:   customer)
      end
    end

    task submit: :environment do
      ENV['DATA_API_ENV'] = 'production'
      ENV['SOLAR_CITY_LEAD_URL'] = 'https://sctypowur.cloudhub.io/powur'
      LEADS.each do |lead|
        quote = Quote.find(lead[:id])
        quote.submit!
        # puts quote.ready_to_submit?
      end
    end
  end
end
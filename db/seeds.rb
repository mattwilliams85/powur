
User.create(
  email:        'jon@sunstand.com', 
  password:     'solarpower', 
  first_name:   'Jonanthan', 
  last_name:    'Budd',
  phone:        '858.555.1212',
  zip:          '92023',
  url_slug:     'jon' )

User.create(
  email:        'paul.walker@eyecuelab.com', 
  password:     'solarpower', 
  first_name:   'Paul', 
  last_name:    'Walker',
  phone:        '310.922.2629',
  zip:          '92127',
  url_slug:     'paul' )

User.create(
  email:        'rick.hou@eyecuelab.com', 
  password:     'solarpower', 
  first_name:   'Rick', 
  last_name:    'Hou',
  phone:        '720.555.1212',
  zip:          '97212',
  url_slug:     'rick' )

User.create(
  email:        'kevin.ponto@eyecuelab.com', 
  password:     'solarpower', 
  first_name:   'Kevin', 
  last_name:    'Ponto',
  phone:        '805.555.1212',
  zip:          '93101',
  url_slug:     'kevin' )

Product.create(
  name: 'SunRun Solar Item', 
  business_volume: 400.00, 
  quote_data: %w(utility rate_schedule roof_material roof_age kwh))


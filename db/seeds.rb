
User.create(
  email:        'jon@sunstand.com', 
  password:     'solarpower', 
  first_name:   'Jonanthan', 
  last_name:    'Budd',
  phone:        '858.555.1212',
  zip:          '92023',
  url_slug:     'jon',
  roles:        [ 'admin' ] )

User.create(
  email:        'paul.walker@eyecuelab.com', 
  password:     'solarpower', 
  first_name:   'Paul', 
  last_name:    'Walker',
  phone:        '858.555.1212',
  zip:          '92023',
  url_slug:     'paul',
  roles:        [ 'admin' ] )

User.create(
  email:        'rick.hou@eyecuelab.com', 
  password:     'solarpower', 
  first_name:   'Rick', 
  last_name:    'Hou',
  phone:        '858.555.1212',
  zip:          '92023',
  url_slug:     'rick',
  roles:        [ 'admin' ] )

User.create(
  email:        'kevin.ponto@eyecuelab.com', 
  password:     'solarpower', 
  first_name:   'Kevin', 
  last_name:    'Ponto',
  phone:        '858.555.1212',
  zip:          '92023',
  url_slug:     'kevin',
  roles:        [ 'admin' ] )

Product.create(
  name: 'SunRun Solar Item', 
  commissionable_volume: 400, 
  quote_data: %w(utility rate_schedule roof_material roof_age kwh))


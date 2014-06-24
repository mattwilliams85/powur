
User.create(
  email:        'jon@sunstand.com', 
  password:     'solarpower', 
  first_name:   'Jonanthan', 
  last_name:    'Budd',
  contact:      { 'phone' => '858.555.1212', 'zip' => '92023' },
  url_slug:     'jon',
  roles:        [ 'admin' ] )

User.create(
  email:        'paul.walker@eyecuelab.com', 
  password:     'solarpower', 
  first_name:   'Paul', 
  last_name:    'Walker',
  contact:      { 'phone' => '858.555.1212', 'zip' => '92023' },
  url_slug:     'paul',
  roles:        [ 'admin' ] )

User.create(
  email:        'rick.hou@eyecuelab.com', 
  password:     'solarpower', 
  first_name:   'Rick', 
  last_name:    'Hou',
  contact:      { 'phone' => '858.555.1212', 'zip' => '92023' },
  url_slug:     'rick',
  roles:        [ 'admin' ] )

User.create(
  email:        'kevin.ponto@eyecuelab.com', 
  password:     'solarpower', 
  first_name:   'Kevin', 
  last_name:    'Ponto',
  contact:      { 'phone' => '858.555.1212', 'zip' => '92023' },
  url_slug:     'kevin',
  roles:        [ 'admin' ] )

Product.create(
  name: 'SunRun Solar Item', 
  business_volume: 400.00, 
  quote_data: %w(utility rate_schedule roof_material roof_age kwh))


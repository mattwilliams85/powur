
puts 'Seeding Admin users'
User.destroy_all

jon = User.create(
  email:      'jon@sunstand.com',
  password:   'solarpower',
  first_name: 'Jonathan',
  last_name:  'Budd',
  phone:      '858.555.1212',
  zip:        '92023',
  url_slug:   'jon',
  roles:      [ 'admin' ],
  created_at: 2.years.ago)

User.create(
  email:      'paul.walker@eyecuelab.com',
  password:   'solarpower',
  first_name: 'Paul',
  last_name:  'Walker',
  phone:      '858.555.1212',
  zip:        '92023',
  url_slug:   'paul',
  roles:      [ 'admin' ],
  created_at: 2.years.ago)

User.create(
  email:      'rick.hou@eyecuelab.com',
  password:   'solarpower',
  first_name: 'Rick',
  last_name:  'Hou',
  phone:      '858.555.1212',
  zip:        '92023',
  url_slug:   'rick',
  roles:      [ 'admin' ],
  created_at: 2.years.ago)

User.create(
  email:      'daniel.mcalerney@eyecuelab.com',
  password:   'solarpower',
  first_name: 'Daniel',
  last_name:  'Mcalerney',
  phone:      '858.555.1212',
  zip:        '92023',
  url_slug:   'daniel',
  roles:      [ 'admin' ],
  created_at: 2.years.ago)

User.create(
  email:      'andrew.westling@eyecuelab.com',
  password:   'solarpower',
  first_name: 'Andrew',
  last_name:  'Westling',
  phone:      '666.666.1212',
  zip:        '92023',
  url_slug:   'andrew',
  roles:      [ 'admin' ],
  created_at: 2.years.ago)

User.create(
  email:      'matthew.williams@eyecuelab.com',
  password:   'solarpower',
  first_name: 'Matthew',
  last_name:  'Williams',
  phone:      '777.777.1212',
  zip:        '92023',
  url_slug:   'matthew',
  roles:      [ 'admin' ],
  created_at: 2.years.ago)

User.create(
  email:      'sasha.shamne@eyecuelab.com',
  password:   'solarpower',
  first_name: 'Sasha',
  last_name:  'Shamne',
  phone:      '777.777.1212',
  zip:        '92023',
  url_slug:   'sasha',
  roles:      [ 'admin' ],
  created_at: 2.years.ago)

User.create(
  email:      'robert@sunstand.com',
  password:   'solarpower',
  first_name: 'Robert',
  last_name:  'Styler',
  phone:      '777.777.1212',
  zip:        '92023',
  url_slug:   'robert',
  roles:      [ 'admin' ],
  created_at: 2.years.ago,
  sponsor_id: jon.id)

User.create(
  email:      'andrea@sunstand.com',
  password:   'solarpower',
  first_name: 'Andrea',
  last_name:  'Budd',
  phone:      '777.777.1212',
  zip:        '92023',
  url_slug:   'andrea',
  roles:      [ 'admin' ],
  created_at: 2.years.ago,
  sponsor_id: jon.id)

puts 'Seeding Bonus Plan'
BonusPlan.destroy_all
BonusPlan.create(
  id:          1,
  name:        'SunStand Compensation Plan',
  start_year:  2014,
  start_month: 5)

puts 'Seeding Api Client Credentials'
ApiClient.destroy_all
ApiClient.create!(
  id:     'ios.sunstand.com',
  secret: 'ecef509dcfe10f9920469d0b99dd853ff2a2021122ea41e98ae2c64050643f20462cba8e56ae7ecd4bd2915d56720871907e33b191db11a0d4603c33892a')


puts 'Seeding Admin users'
User.destroy_all

jon = User.create!(
  email:      'jon@powur.com',
  password:   'solarpower',
  password_confirmation: 'solarpower',
  tos: true,
  first_name: 'Jonathan',
  last_name:  'Budd',
  phone:      '858.555.1212',
  zip:        '92023',
  url_slug:   'jon',
  roles:      [ 'admin' ],
  smarteru_employee_id: '1')

User.create!(
  email:      'paul.walker@eyecuelab.com',
  password:   'solarpower',
  password_confirmation: 'solarpower',
  tos: true,
  first_name: 'Paul',
  last_name:  'Walker',
  phone:      '858.555.1212',
  zip:        '92023',
  url_slug:   'paul',
  roles:      [ 'admin' ])

User.create!(
  email:      'rick.hou@eyecuelab.com',
  password:   'solarpower',
  password_confirmation: 'solarpower',
  tos: true,
  first_name: 'Rick',
  last_name:  'Hou',
  phone:      '858.555.1212',
  zip:        '92023',
  url_slug:   'rick',
  roles:      [ 'admin' ],
  smarteru_employee_id: '3')

User.create!(
  email:      'andrew.westling@eyecuelab.com',
  password:   'solarpower',
  password_confirmation: 'solarpower',
  tos: true,
  first_name: 'Andrew',
  last_name:  'Westling',
  phone:      '666.666.1212',
  zip:        '92023',
  url_slug:   'andrew',
  roles:      [ 'admin' ],
  smarteru_employee_id: '5')

User.create!(
  email:      'matthew.williams@eyecuelab.com',
  password:   'solarpower',
  password_confirmation: 'solarpower',
  tos: true,
  first_name: 'Matthew',
  last_name:  'Williams',
  phone:      '777.777.1212',
  zip:        '92023',
  url_slug:   'matthew',
  roles:      [ 'admin' ])

User.create!(
  email:      'sasha.shamne@eyecuelab.com',
  password:   'solarpower',
  password_confirmation: 'solarpower',
  tos: true,
  first_name: 'Sasha',
  last_name:  'Shamne',
  phone:      '777.777.1212',
  zip:        '92023',
  url_slug:   'sasha',
  roles:      [ 'admin' ],
  smarteru_employee_id: '7')

User.create!(
  email:      'robert@powur.com',
  password:   'solarpower',
  password_confirmation: 'solarpower',
  tos: true,
  first_name: 'Robert',
  last_name:  'Styler',
  phone:      '777.777.1212',
  zip:        '92023',
  url_slug:   'robert',
  roles:      [ 'admin' ],
  sponsor_id: jon.id,
  smarteru_employee_id: '8')

User.create!(
  email:      'andrea@powur.com',
  password:   'solarpower',
  password_confirmation: 'solarpower',
  tos: true,
  first_name: 'Andrea',
  last_name:  'Budd',
  phone:      '777.777.1212',
  zip:        '92023',
  url_slug:   'andrea',
  roles:      [ 'admin' ],
  sponsor_id: jon.id)

puts 'Seeding Bonus Plan'
BonusPlan.destroy_all
BonusPlan.create!(
  id:          1,
  name:        'SunStand Compensation Plan',
  start_year:  2014,
  start_month: 5)

puts 'Seeding Api Client Credentials'
ApiClient.destroy_all
ApiClient.create!(
  id:     'ios.sunstand.com',
  secret: 'ecef509dcfe10f9920469d0b99dd853ff2a2021122ea41e98ae2c64050643f20462cba8e56ae7ecd4bd2915d56720871907e33b191db11a0d4603c33892a')

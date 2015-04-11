
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
  smarteru_employee_id: 'jon@powur.com')

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
  smarteru_employee_id: 'rick.hou@eyecuelab.com')

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
  smarteru_employee_id: 'andrew.westling@eyecuelab.com')

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
  smarteru_employee_id: 'sasha.shamne@eyecuelab.com')

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
  smarteru_employee_id: 'robert@powur.com')

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

User.create!(
  email:      'demo@powur.com',
  password:   'sunshine',
  password_confirmation: 'sunshine',
  tos: true,
  first_name: 'Demo',
  last_name:  'User',
  phone:      '777.777.1212',
  zip:        '92023',
  url_slug:   'demo',
  roles:      [ ],
  sponsor_id: jon.id)

User.create!(
  email:      'demoadmin@powur.com',
  password:   'sunlight',
  password_confirmation: 'sunlight',
  tos: true,
  first_name: 'Demo',
  last_name:  'Administrator',
  phone:      '777.777.1212',
  zip:        '92023',
  url_slug:   'demo',
  roles:      [ 'admin' ])

puts 'Seeding Bonus Plan'
BonusPlan.destroy_all
BonusPlan.create!(
  id:          1,
  name:        'SunStand Compensation Plan',
  start_year:  2014,
  start_month: 5)

puts 'Seeding Resources'
Resource.destroy_all
Resource.create!(
  user_id: jon.id,
  title: 'Powur awesome pdf file',
  description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
  file_original_path: 'http://eyecuelab.com/doc.pdf',
  file_type: 'application/pdf',
  is_public: true
)
Resource.create!(
  user_id: jon.id,
  title: 'Powur awesome video',
  description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
  file_original_path: 'http://eyecuelab.com/video.mp4',
  file_type: 'video/mp4',
  is_public: true
)

puts 'Seeding Api Client Credentials'
ApiClient.destroy_all
ApiClient.create!(
  id:     'ios.sunstand.com',
  secret: 'ecef509dcfe10f9920469d0b99dd853ff2a2021122ea41e98ae2c64050643f20462cba8e56ae7ecd4bd2915d56720871907e33b191db11a0d4603c33892a')

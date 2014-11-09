
puts 'Seeding Admin users'
User.destroy_all
User.create(
  email:      'jon@sunstand.com',
  password:   'solarpower',
  first_name: 'Jonanthan',
  last_name:  'Budd',
  phone:      '858.555.1212',
  zip:        '92023',
  url_slug:   'jon',
  roles:      [ 'admin' ])

User.create(
  email:      'paul.walker@eyecuelab.com',
  password:   'solarpower',
  first_name: 'Paul',
  last_name:  'Walker',
  phone:      '858.555.1212',
  zip:        '92023',
  url_slug:   'paul',
  roles:      [ 'admin' ])

User.create(
  email:      'rick.hou@eyecuelab.com',
  password:   'solarpower',
  first_name: 'Rick',
  last_name:  'Hou',
  phone:      '858.555.1212',
  zip:        '92023',
  url_slug:   'rick',
  roles:      [ 'admin' ])

User.create(
  email:      'daniel.mcalerney@eyecuelab.com',
  password:   'solarpower',
  first_name: 'Daniel',
  last_name:  'Mcalerney',
  phone:      '858.555.1212',
  zip:        '92023',
  url_slug:   'daniel',
  roles:      [ 'admin' ])

BonusPlan.destroy_all
BonusPlan.create(
  id:          1,
  name:        'SunStand Compensation Plan',
  start_year:  2014,
  start_month: 5)

ApiClient.destroy_all
ApiClient.create!(
  id:     'ios.sunstand.com',
  secret: 'ecef509dcfe10f9920469d0b99dd853ff2a2021122ea41e98ae2c64050643f20462cba8e56ae7ecd4bd2915d56720871907e33b191db11a0d4603c33892a')

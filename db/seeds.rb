# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(
  email:        'jon@sunstand.com', 
  password:     'solarpower', 
  first_name:   'Jonanthan', 
  last_name:    'Budd',
  phone:        '858.555.1212',
  zip:          '92023' )

User.create!(
  email:        'paul.walker@eyecuelab.com', 
  password:     'solarpower', 
  first_name:   'Paul', 
  last_name:    'Walker',
  phone:        '310.922.2629',
  zip:          '92127' )

User.create!(
  email:        'rick.hou@eyecuelab.com', 
  password:     'solarpower', 
  first_name:   'Rick', 
  last_name:    'Hou',
  phone:        '720.555.1212',
  zip:          '97212' )

User.create!(
  email:        'kevin.ponto@eyecuelab.com', 
  password:     'solarpower', 
  first_name:   'Kevin', 
  last_name:    'Ponto',
  phone:        '805.555.1212',
  zip:          '93101' )

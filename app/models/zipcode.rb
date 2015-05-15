class Zipcode < ActiveRecord::Base
  validates :zip, uniqueness: true
end
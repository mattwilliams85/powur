class Qualification < ActiveRecord::Base

  belongs_to :rank
  belongs_to :path, class_name: 'QualificationPath'

end
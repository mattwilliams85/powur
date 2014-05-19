class Invite < ActiveRecord::Base

  belongs_to :invitor, class_name: 'User'
  belongs_to :invitee, class_name: 'User'
  
  attr_accessor :id

  after_initialize do
    self.id = SecureRandom.hex(3).upcase unless self.persisted?
  end

end

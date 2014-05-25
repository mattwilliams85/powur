class Invite < ActiveRecord::Base

  belongs_to :invitor, class_name: 'User'
  belongs_to :invitee, class_name: 'User'

  before_validation do
    self.id ||= Invite.generate_code
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  class << self
    def generate_code
      SecureRandom.hex(3).upcase
    end
  end

end

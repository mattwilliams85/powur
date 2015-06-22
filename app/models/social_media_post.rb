class SocialMediaPost < ActiveRecord::Base
  validates_presence_of :content
end

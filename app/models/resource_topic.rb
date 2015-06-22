class ResourceTopic < ActiveRecord::Base
  validates :title,
            presence:   true,
            uniqueness: { message: 'This topic title is taken' }

  def as_json(*)
    {
      id:       id,
      title:    title,
      position: position
    }
  end
end

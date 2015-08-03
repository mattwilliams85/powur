class Notification < ActiveRecord::Base
  belongs_to :user
  has_many :releases, class_name: 'NotificationRelease', dependent: :destroy

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 160 }

  scope :sorted, -> { order(id: :desc) }
end

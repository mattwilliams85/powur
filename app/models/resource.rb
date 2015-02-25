class Resource < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :file_original_path, presence: true
  validates :file_type,
    presence: true,
    inclusion: {
      in: ['application/pdf', 'video/mp4'],
      message: "File type can't be accepted"
    }

  scope :published, -> { where(is_public: true) }
  scope :videos, -> { where(file_type: 'video/mp4') }
  scope :documents, -> { where(file_type: 'application/pdf') }
end

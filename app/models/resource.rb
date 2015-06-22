class Resource < ActiveRecord::Base

  RESOURCE_FILE_TYPES = {
    video: 'video/mp4',
    document: 'application/pdf'
  }

  SEARCH = ':q % title or :q % description'

  belongs_to :user
  belongs_to :topic, class_name: 'ResourceTopic'

  validates :user_id, presence: true
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true
  validates :file_original_path, presence: true, if: 'youtube_id.blank?'
  validates :file_type,
    presence: true,
    inclusion: {
      in: RESOURCE_FILE_TYPES.values,
      message: "File type can't be accepted"
    }

  scope :published, -> { where(is_public: true) }
  scope :videos, -> { where(file_type: RESOURCE_FILE_TYPES[:video]) }
  scope :documents, -> { where(file_type: RESOURCE_FILE_TYPES[:document]) }
  scope :search, ->(q) { where(SEARCH, q: "#{q}") }
  scope :sorted, -> { order('resources.position asc, resources.id desc') }
  scope :with_topics, -> { joins(:topic).includes(:topic) }

  before_validation :set_file_type

  private

  def set_file_type
    if youtube_id.present?
      self.file_type = RESOURCE_FILE_TYPES[:video]
      return
    end

    return unless file_original_path.present?

    ext = file_original_path[/\.(\w*)$/, 1]
    self.file_type = case ext
    when 'mp4'
      RESOURCE_FILE_TYPES[:video]
    when 'pdf'
      RESOURCE_FILE_TYPES[:document]
    else
      ext
    end
  end
end

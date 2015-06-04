class ApplicationAgreement < ActiveRecord::Base
  validates :version,
    uniqueness: { message: 'This version is taken' },
    presence: true
  validates :document_path,
    presence: true

  scope :published, -> { where('published_at is not null') }
  scope :sorted, -> { order('id desc') }

  class << self
    def current
      published.sorted.first
    end
  end

  def as_json(*)
    {
      version: version,
      document_path: document_path,
      message: message
    }
  end
end

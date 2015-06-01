class ApplicationAgreement < ActiveRecord::Base
  validates_presence_of :version, :document_path

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
      document_path: document_path
    }
  end
end

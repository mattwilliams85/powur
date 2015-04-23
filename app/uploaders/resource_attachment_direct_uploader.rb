require 'carrierwave_direct'

class ResourceAttachmentDirectUploader < CarrierWave::Uploader::Base
  include CarrierWaveDirect::Uploader

  self.max_file_size = 200.megabytes

  def fog_directory
    ENV['AWS_BUCKET']
  end

  def store_dir
    'resource_original_attachments'
  end
end

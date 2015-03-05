require "carrierwave_direct"

class ResourceImageDirectUploader < CarrierWave::Uploader::Base
  include CarrierWaveDirect::Uploader

  self.max_file_size = 2.megabytes

  def fog_directory
    Rails.application.secrets.aws_bucket
  end

  def store_dir
    'resource_original_images'
  end
end

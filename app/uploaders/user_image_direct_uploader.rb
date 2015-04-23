require 'carrierwave_direct'

class UserImageDirectUploader < CarrierWave::Uploader::Base
  include CarrierWaveDirect::Uploader

  self.max_file_size = 5.megabytes

  def fog_directory
    ENV['AWS_BUCKET']
  end

  def store_dir
    'user_original_images'
  end
end

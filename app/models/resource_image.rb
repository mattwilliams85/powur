require 'carrierwave/mount'

class ResourceImage
  extend CarrierWave::Mount

  mount_uploader :image_direct, ResourceImageDirectUploader
end

require 'carrierwave/mount'

class UserImage
  extend CarrierWave::Mount

  mount_uploader :image_direct, UserImageDirectUploader
end

require 'carrierwave/mount'

class ResourceAttachment
  extend CarrierWave::Mount

  mount_uploader :attachment_direct, ResourceAttachmentDirectUploader
end

module PaperclipScopes
  extend ActiveSupport::Concern

  included do
    aws_bucket = Rails.application.secrets.aws_bucket
    aws_access_key_id = Rails.application.secrets.aws_access_key_id
    aws_secret_key = Rails.application.secrets.aws_secret_access_key
    has_attached_file :avatar,
      path:            '/avatars/:id/:basename_:style.:extension',
      url:             ':s3_domain_url',
      default_url:     '/temp_dev_images/Tim.jpg',
      storage:         :s3,
      s3_credentials:  { bucket:            aws_bucket,
                         access_key_id:     aws_access_key_id,
                         secret_access_key: aws_secret_key },
    styles:          {
      thumb:   [ '128x128#', :jpg, quality: 70 ],
      preview: [ '480x480#', :jpg, quality: 70 ],
      large:   [ '600>',     :jpg, quality: 70 ],
    retina:  [ '1200>',    :jpg, quality: 30 ] },
    convert_options: {
      thumb:   '-set colorspace sRGB -strip',
      preview: '-set colorspace sRGB -strip',
      large:   '-set colorspace sRGB -strip',
    retina:  '-set colorspace sRGB -strip -sharpen 0x0.5' }

    # Validate content type
    validates_attachment_content_type :avatar, content_type: /\Aimage/
    # Validate filename
    validates_attachment_file_name :avatar, matches: [/png\Z/, /jpe?g\Z/, /gif\Z/]
    # Explicitly do not validate
    do_not_validate_attachment_file_type :avatar
  end

  module ClassMethods

  def delete_avatar
    self.avatar = nil
  end

  end
end

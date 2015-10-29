module PaperclipScopes
  extend ActiveSupport::Concern

  included do
    aws_bucket = ENV['AWS_BUCKET']
    aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws_secret_key = ENV['AWS_SECRET_ACCESS_KEY']
    has_attached_file(
      :avatar,
      path:            '/avatars/:id/:basename_:style.:extension',
      url:             ':s3_domain_url',
      storage:         :s3,
      s3_credentials:  { bucket:            aws_bucket,
                         access_key_id:     aws_access_key_id,
                         secret_access_key: aws_secret_key },
      keep_old_files:  true,
      s3_protocol:     :https,
      styles:          {
        thumb:   [ '128x128#', :jpg, quality: 70 ],
        preview: [ '480x480#', :jpg, quality: 70 ],
        large:   [ '600>',     :jpg, quality: 70 ],
        retina:  [ '1200>',    :jpg, quality: 30 ] },
      convert_options: {
        thumb:   '-set colorspace sRGB -strip',
        preview: '-set colorspace sRGB -strip',
        large:   '-set colorspace sRGB -strip',
        retina:  '-set colorspace sRGB -strip -sharpen 0x0.5' })

    # Validate content type
    # validates_attachment_content_type :avatar, content_type: /\Aimage/
    # Validate filename
    validates_attachment_file_name(
      :avatar,
      matches: [/png\Z/, /jpe?g\Z/, /gif\Z/])
    # Explicitly do not validate
    do_not_validate_attachment_file_type :avatar
  end

  def avatar_remote_url=(url_value)
    self.avatar = URI.parse(URI.encode(url_value))
    @avatar_remote_url = url_value
  end

  module ClassMethods
    def process_image_original_path!(id)
      instance = find(id)
      instance.avatar_remote_url = instance.image_original_path
      instance.save!
    end
  end
end

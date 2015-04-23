module Auth
  class UploaderConfigController < AuthController
    before_filter :set_uploader

    def show
      @uploader.class.use_action_status = true
      @uploader.success_action_status = '201'

      data = {
        'key'            => @uploader.key.gsub(/\${filename}/, ''),
        'AWSAccessKeyId' => ENV['AWS_ACCESS_KEY_ID'],
        's3Policy'       => @uploader.policy,
        's3Signature'    => @uploader.signature,
        'bucket'         => ENV['AWS_BUCKET']
      }
      render json: data
    end

    private

    def set_uploader
      @uploader = case params[:mode]
      when 'resource_attachment'
        valid_mime_types = ['video/mp4', 'application/pdf']
        head :unprocessable_entity unless valid_mime_types.include?(params[:mimetype])
        ResourceAttachment.new.attachment_direct
      when 'resource_image'
        ResourceImage.new.image_direct
      when 'user_image'
        UserImage.new.image_direct
      end
    end
  end
end

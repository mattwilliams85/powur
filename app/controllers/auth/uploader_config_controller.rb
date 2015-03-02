module Auth
  class UploaderConfigController < AuthController
    before_filter :set_uploader

    def show
      @uploader.class.use_action_status = true
      @uploader.success_action_status = '201'

      data = {
        "key" => @uploader.key.gsub(/\${filename}/, ''),
        "AWSAccessKeyId" => Rails.application.secrets.aws_access_key_id,
        "s3Policy" => @uploader.policy,
        "s3Signature" => @uploader.signature,
        "bucket" => Rails.application.secrets.aws_bucket
      }
      render json: data
    end

    private

    def set_uploader
      @uploader = case params[:mode]
      when "resource_attachment"
        ResourceAttachment.new.attachment_direct
      end
    end
  end
end

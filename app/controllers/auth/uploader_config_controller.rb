module Auth
  class UploaderConfigController < AuthController
    before_filter :validate_content_type

    def show
      data = {
        'key'            => key + '${filename}',
        'acl'            => acl,
        'awsAccessKeyId' => ENV['AWS_ACCESS_KEY_ID'],
        's3Policy'       => policy,
        's3Signature'    => signature,
        's3Bucket'       => ENV['AWS_BUCKET']
      }
      render json: { config: data }
    end

    private

    def validate_content_type
      case params[:mode]
      when 'resource_attachment'
        valid_mime_types = ['video/mp4', 'application/pdf']
        head :unprocessable_entity unless valid_mime_types.include?(params[:mimetype])
        @key_prefix = 'resource_original_attachments'
        @max_content_length = 100.megabytes
      when 'resource_image'
        @key_prefix = 'resource_original_images'
        @max_content_length = 5.megabytes
      when 'user_image'
        @key_prefix = 'user_original_images'
        @max_content_length = 5.megabytes
      end
    end

    def policy_expiration
      @policy_expiration ||= 10.hours.from_now.utc.iso8601
    end

    def acl
      'public-read'
    end

    def key_prefix
      @key_prefix ||= 'uploads'
    end

    def key
      @key ||= "#{key_prefix}/#{SecureRandom.hex}/"
    end

    def max_content_length
      @max_content_length ||= 100.megabytes
    end

    def policy
      @policy ||= Base64.encode64(policy_data.to_json).gsub("\n", '')
    end

    def policy_data
      {
        expiration: policy_expiration,
        conditions: [
          [ 'starts-with', '$key', key ],
          { bucket: ENV['AWS_BUCKET'] },
          { acl: acl },
          { success_action_status: '201' },
          [ 'content-length-range', 1, max_content_length ]
        ]
      }
    end

    def signature
      Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest.new('sha1'),
          ENV['AWS_SECRET_ACCESS_KEY'],
          policy
        )
      ).gsub("\n", '')
    end
  end
end

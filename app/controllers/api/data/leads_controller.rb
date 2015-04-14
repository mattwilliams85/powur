module Api
  module Data
    class LeadsController < ApiController
      def create
        attrs = record_to_lead_attrs(params)

        begin
          lead_update = LeadUpdate.create!(attrs)
        rescue ActiveRecord::InvalidForeignKey => e
          api_error!(:invalid_request, :invalid_params, params: 'uid')
        end

        render json: { leadUpdateId: lead_update.id }, status: :created
      end

      def batch
      end

      private

      def record_to_lead_attrs(record)
        require_input(:uid, :providerUid, :status)

        prefix, quote_id = params[:uid].split(':')
        validate_prefix(prefix)

        key_dates = record[:keyDates]
        order_status = (record[:order] || {})[:status]

        opp = record[:opportunity] || {}
        { quote_id:           quote_id.to_i,
          provider_uid:       record[:providerUid],
          status:             record[:status],
          contact:            record[:contact],
          order_status:       order_status,
          consultation:       date_from_string(key_dates[:consultation]),
          contract:           date_from_string(key_dates[:contract]),
          installation:       date_from_string(key_dates[:installation]) }
      end

      def validate_prefix(prefix)
        return if prefix == QuoteSubmission.id_prefix
        api_error!(:invalid_request,
                   :environment_mismatch,
                   env: prefix.split('.').first)
      end

      def date_from_string(value)
        DateTime.parse()
      end
    end
  end
end
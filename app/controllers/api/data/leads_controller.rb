module Api
  module Data
    class LeadsController < ApiController
      def create
        attrs = record_to_lead_attrs(params)
        lead_update = create_lead_update(attrs)

        render json: lead_update.to_h, status: :created
      end

      def batch
        require_input(:batch)

        lead_updates = params[:batch].map do |update_params|
          begin
            attrs = record_to_lead_attrs(update_params)
            lead_update = create_lead_update(attrs)
            lead_update.to_h
          rescue Errors::ApiError => e
            e.to_h.merge(providerUid: update_params[:providerUid])
          end
        end

        render json: { updates: lead_updates }
      end

      private

      def validate_prefix(prefix)
        return if prefix == QuoteSubmission.id_prefix

        api_error!(:invalid_request,
                   :environment_mismatch,
                   env: prefix.split('.').first)
      end

      def date_from_string(value)
        DateTime.parse(value)
      end

      REQUIRED_PARAMS = [ :uid, :providerUid, :status ]
      def record_to_lead_attrs(record)
        missing = REQUIRED_PARAMS.select { |p| record[p].nil? }
        unless missing.empty?
          api_error!(:invalid_request, :missing_params, params: missing.join(','))
        end

        prefix, quote_id = record[:uid].split(':')
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

      def create_lead_update(attrs)
        LeadUpdate.create!(attrs)

      rescue ActiveRecord::InvalidForeignKey => e
        api_error!(:invalid_request, :invalid_params, params: 'uid')
      end
    end
  end
end
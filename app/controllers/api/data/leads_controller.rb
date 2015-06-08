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

      def fetch_quote(external_id)
        quote = Quote.find_by_external_id(external_id)
        unless quote
          api_error!(:invalid_request,
                     :environment_mismatch,
                     env: external_id.split(':').first.split('.'))
        end
        return quote
      rescue ActiveRecord::RecordNotFound
        invalid_quote_id_error!
      end

      def date_from_string(value)
        DateTime.parse(value)
      end

      REQUIRED_PARAMS = [ :uid, :providerUid, :status, :lastUpdated ]
      KEY_DATES = %w(consultation contract installation)
      def record_to_lead_attrs(record)
        missing = REQUIRED_PARAMS.select { |p| record[p].nil? }
        unless missing.empty?
          api_error!(:invalid_request, :missing_params, params: missing.join(','))
        end

        quote = fetch_quote(record[:uid])
        order_status = (record[:order] || {})[:status]

        opp = record[:opportunity] || {}
        attrs = { 
          quote_id:           quote.id,
          provider_uid:       record[:providerUid],
          status:             record[:status],
          lead_status:        record[:leadStatus],
          opportunity_stage:  record[:opportunityStage],
          contact:            record[:contact],
          order_status:       order_status,
          updated_at:         date_from_string(record[:lastUpdated]) }
        record[:keyDates].each do |key, value|
          if !value.nil? && KEY_DATES.include?(key.to_s)
            attrs[key] = date_from_string(value)
          end
        end if record[:keyDates]

        attrs
      end

      def create_lead_update(attrs)
        LeadUpdate.create!(attrs)

      rescue ActiveRecord::InvalidForeignKey => e
        invalid_quote_id_error!
      end

      def invalid_quote_id_error!
        api_error!(:invalid_request, :invalid_params, params: 'uid')
      end
    end
  end
end
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
      def record_to_lead_attrs(record)
        missing = REQUIRED_PARAMS.select { |p| record[p].nil? }
        unless missing.empty?
          api_error!(:invalid_request, :missing_params, params: missing.join(','))
        end

        quote = fetch_quote(record[:uid])

        key_dates = record[:keyDates]
        order_status = (record[:order] || {})[:status]

        opp = record[:opportunity] || {}
        { quote_id:           quote.id,
          provider_uid:       record[:providerUid],
          status:             record[:status],
          lead_status:        record[:leadStatus],
          opportunity_stage:  record[:opportunityStage],
          contact:            record[:contact],
          order_status:       order_status,
          updated_at:         date_from_string(record[:lastUpdated]),
          consultation:       date_from_string(key_dates[:consultation]),
          contract:           date_from_string(key_dates[:contract]),
          installation:       date_from_string(key_dates[:installation]) }
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
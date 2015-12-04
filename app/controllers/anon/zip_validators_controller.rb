module Anon
  class ZipValidatorsController < AnonController
    before_action :fetch_lead, only: [ :create ]

    def create
      require_input :zip
      error!(:invalid_zip, :zip) unless Lead.valid_zip?(params[:zip])

      if Lead.eligible_zip?(params[:zip])
        @is_valid = true
        @lead.zip = params[:zip]
        @lead.invite_status = :initiated
        @lead.save!
      else
        status = Lead.data_statuses[:ineligible_location]
        @lead.update_attributes(data_status: status, zip: nil)
        error!(:unqualified_zip, :zip)
      end
    rescue Lead::ZipApiError
      error!(:zip_api)
    end

    def validate
      require_input :zip
      @is_valid = Lead.eligible_zip?(params[:zip])

      render 'validate'
    end

    private

    def fetch_lead
      @lead = Lead.find_by(code: params[:code])
      not_found!(:product_invite) unless @lead
    end
  end
end

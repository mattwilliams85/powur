module Admin
  class EwalletSandboxController < AdminController
    include EwalletDSL
    require 'time'
    respond_to :html, :json
    def index
      @rand_test_acct = rand(99)
      @batch_id = Time.now.to_i
      respond_to do |format|
        format.html do

        end
        format.json do

        end
      end
    end

    def call
      @response = ewallet_request(params['api_method'], params['options_hash'])
      # puts '!!!!!!RESPONSE FROM CONTROLLER'
      # puts @response
      # respond_with do |format|
      #   format.json { render json: @response, status: :ok }
      # end
    end
  end
end

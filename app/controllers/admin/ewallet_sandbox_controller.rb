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
      api_method = params['api_method'].parameterize.underscore.to_sym

      @response = ewallet_request(api_method, params['options_hash'])
    end
  end
end

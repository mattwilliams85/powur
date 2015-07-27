module Admin
  class TwilioPhoneNumbersController < AdminController
    before_action :fetch_client, only: [ :index ]

    def index
      @phone_numbers = @twilio_client.purchased_numbers
    rescue Twilio::REST::RequestError
      @phone_numbers = []
    end

    private

    def fetch_client
      @twilio_client = TwilioClient.new
    end
  end
end

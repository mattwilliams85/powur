module QuoteSubmission
  extend ActiveSupport::Concern

  def submit!
    form = SolarCityForm.new(self)
    form.post
    fail(form.error) if form.error? && !form.dupe?
    update(provider_uid: form.provider_uid)
    touch(:submitted_at)
  end

  class << self
    def id_prefix
      sub = ENV['DATA_API_ENV'] || Rails.env
      "#{sub}.powur.com"
    end

    def id_to_external(id)
      "#{id_prefix}:#{id}"
    end
  end

  class SolarCityForm
    attr_reader :quote, :response, :parsed_response

    def initialize(quote)
      @quote = quote
    end

    def customer
      quote.customer
    end

    def post
      url = ENV['SOLAR_CITY_LEAD_URL'] || fail('Missing SOLAR_CITY_LEAD_URL env var')
      @response = RestClient.post(url, post_body)
    rescue RestClient::InternalServerError => e
      @error = e
      @response = e.inspect
    end

    def provider_uid
      created_id || dupe_id
    end

    def parsed_response
      @parsed_response ||= MultiJson.decode(response)
    rescue => e
      @error = e
      @response = e.inspect
    end

    def created_id
      parsed_response['LeadId'].presence
    end

    def error
      @error ||= begin
        parsed_response &&
          parsed_response['Status'] != 'SUCCESS' &&
          parsed_response['Message']
      end
    end

    def error?
      error
    end

    DUPE_REGEX = /duplicates value on record with id: (?<id>\w+$)/
    def dupe_match
      @dupe_match ||= error.match(DUPE_REGEX)
    end

    def dupe?
      dupe_match
    end

    def dupe_id
      dupe_match[:id]
    end

    def post_body
      { 'External_ID__c'           => QuoteSubmission.id_to_external(quote.id),
        'Lead_Generator__c'        => quote.user_id,
        'FirstName'                => customer.first_name,
        'LastName'                 => customer.last_name,
        'Street'                   => customer.address,
        'City'                     => customer.city,
        'PostalCode'               => customer.zip,
        'Phone'                    => customer.phone,
        'Email'                    => customer.email,
        'Monthly_Electric_Bill__c' => quote.data['average_bill'] }
    end
  end
end
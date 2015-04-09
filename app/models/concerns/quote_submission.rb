module QuoteSubmission
  extend ActiveSupport::Concern

  def submit!
    form = SolarCityForm.new(self)
    form.post
    fail(form.error) if form.error? && !form.dupe?
    update(provider_uid: form.provider_uid)
    touch(:submitted_at)
  end

  class SolarCityForm
    attr_reader :quote, :response, :parsed_response

    def initialize(quote)
      @quote = quote
    end

    def customer
      quote.customer
    end

    POST_URL = 'https://sctyleads-test.cloudhub.io/powur'
    def post
      @response = RestClient.post(POST_URL, post_body)
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
    # private

    def id_prefix
      "#{Rails.env}.powur.com:"
    end

    def post_body
      { 'External_ID__c'           => "#{id_prefix}#{quote.id}",
        'Lead_Generator__c'        => quote.user_id,
        'FirstName'                => customer.first_name,
        'LastName'                 => customer.last_name,
        'Street'                   => customer.address,
        'City'                     => customer.city,
        'PostalCode'               => customer.zip,
        'Phone'                    => customer.phone,
        'Email'                    => customer.email,
        'submit'                   => 'Submit',
        'Monthly_Electric_Bill__c' => quote.data['average_bill'] }
    end
  end
end
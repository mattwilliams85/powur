class SolarCityForm
  attr_reader :lead, :response, :parsed_response, :request_error

  def initialize(lead)
    @lead = lead
  end

  def post
    url = ENV['SOLAR_CITY_LEAD_URL']
    @response = RestClient::Request.execute(
      method:       :post,
      url:          url,
      payload:      post_body,
      timeout:      10,
      open_timeout: 5)
    fail(error) if error? && !dupe?
  rescue => e
    raise IntegrationError.new(e), "Solar City Lead Submit Error: #{e.message}"
  end

  def provider_uid
    created_id || dupe_id
  end

  def response_date
    @response_date ||= DateTime.parse(response.headers[:date])
  end

  def parsed_response
    @parsed_response ||= MultiJson.decode(response.gsub("\n", ''))
  rescue MultiJson::ParseError => e
    raise IntegrationError.new(e), "Solar City Lead Submit Error: #{response}"
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
    @dupe_match ||= error && error.match(DUPE_REGEX)
  end

  def dupe?
    dupe_match
  end

  def dupe_id
    dupe_match[:id]
  end

  def post_body
    attrs = {
      'External_ID__c'           => Lead.id_to_external(lead.id),
      'Lead_Generator__c'        => lead.user_id,
      'FirstName'                => lead.first_name,
      'LastName'                 => lead.last_name,
      'Street'                   => lead.address,
      'City'                     => lead.city,
      'PostalCode'               => lead.zip,
      'Phone'                    => lead.phone,
      'Email'                    => lead.email,
      'Monthly_Electric_Bill__c' => lead.data['average_bill'],
      'Notes_Description__c'     => lead.notes }
    # if lead.call_consented?
    #   attrs['campaignId'] = ENV['SC_CONSENT_CID']
    #   attrs['campaignStatus'] = 'Confirmed'
    # else
    #   attrs['campaignId'] = ENV['SC_NOCONSENT_CID']
    #   attrs['campaignStatus'] = 'Responded'
    # end

    attrs
  end
end

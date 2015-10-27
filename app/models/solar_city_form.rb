class SolarCityForm
  attr_reader :lead, :response, :parsed_response, :request_error

  def initialize(lead)
    @lead = lead
  end

  def customer
    lead.customer
  end

  def post
    url = ENV['SOLAR_CITY_LEAD_URL']
    @response = RestClient::Request.execute(
      method:       :post,
      url:          url,
      payload:      post_body,
      timeout:      10,
      open_timeout: 5)
  rescue RestClient::RequestFailed => e
    @request_error = e
    @response = e.inspect
  end

  def provider_uid
    created_id || dupe_id
  end

  def parsed_response
    @parsed_response ||= MultiJson.decode(response)
  rescue => e
    @error_response = e
    @response = e.inspect
  end

  def created_id
    parsed_response['LeadId'].presence
  end

  def error_response
    @error_response ||= begin
      parsed_response &&
        parsed_response['Status'] != 'SUCCESS' &&
        parsed_response['Message']
    end
  end

  def error
    request_error || error_response
  end

  def error?
    !error.nil?
  end

  DUPE_REGEX = /duplicates value on record with id: (?<id>\w+$)/
  def dupe_match
    @dupe_match ||= error_response && error_response.match(DUPE_REGEX)
  end

  def dupe?
    dupe_match
  end

  def dupe_id
    dupe_match[:id]
  end

  def post_body
    { 'External_ID__c'           => Lead.id_to_external(lead.id),
      'Lead_Generator__c'        => lead.user_id,
      'FirstName'                => customer.first_name,
      'LastName'                 => customer.last_name,
      'Street'                   => customer.address,
      'City'                     => customer.city,
      'PostalCode'               => customer.zip,
      'Phone'                    => customer.phone,
      'Email'                    => customer.email,
      'Monthly_Electric_Bill__c' => lead.data['average_bill'],
      'Notes_Description__c'     => customer.notes }
  end
end
module LeadUpdateCSV
  CSV_FIELDS = [
    'ExternalId', 'Status', 'LeadId', 'LeadStatus', 'LeadCreatedDate',
    'Days Elapsed', 'OpportunityId', 'OpportunityStage', 'ConsultationDate',
    'SolarworksStatus', 'SolarworksSubStatus', 'ContractSignedDate', 
    'JobCreatedDate', 'InstallationDate', 'LastModified' ]
  META_DATA_FIELDS = [
    'LeadStatus', 'Days Elapsed', 'OpportunityStage',
    'SolarworksStatus', 'SolarworksSubStatus', 'OpportunityId',
    'LeadOwner', 'OpportunityOwner' ]
  DATE_FIELDS = {
    contract:     'JobCreatedDate',
    consultation: 'ConsultationDate',
    installation: 'InstallationDate' }

  def create_from_csv(data)
    headers = data.shift
    record_attrs = data.map do |row|
      attrs_from_csv_row(row_to_hash(row, headers))
    end
    records = create!(record_attrs)
    puts "Created #{records.size} lead update records"
  end

  private

  def row_to_hash(row, headers)
    key_values = headers.each_with_index.map do |key, i|
      [ key, row[i] ]
    end
    Hash[key_values]
  end

  def quote_from_external_id(external_id)
    quote = Quote.find_by_external_id(external_id)
    fail "Environment mismatch for external id: #{external_id}" unless quote
    return quote
  end

  def date_from_string(value)
    DateTime.parse(value)
  rescue ArgumentError
    DateTime.strptime(value, '%m/%d/%Y %H:%M:%S')
  end

  def parse_dates(row_hash)
    key_values = {}

    DATE_FIELDS.each do |key, field|
      value = row_hash[field]
      key_values[key] = date_from_string(value) if value
    end

    key_values
  end

  def attrs_from_csv_row(row_hash)
    external_id = row_hash['ExternalId']
    quote = quote_from_external_id(external_id)
    dates = parse_dates(row_hash)
    
    attrs = {
      quote_id:     quote.id,
      provider_uid: row_hash['LeadId'],
      status:       row_hash['Status'],
      updated_at:   row_hash['LastModified'],
      data:         {} }.merge(dates)
    
    META_DATA_FIELDS.each do |key|
      value = row_hash[key]
      attrs[:data][key] = value if value
    end

    attrs
  end
end

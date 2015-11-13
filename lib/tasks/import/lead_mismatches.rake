namespace :powur do
  namespace :import do
    def mismatch_file_path
      Rails.root.join('db', 'overrides', 'mismatched_leads.csv')
    end

    def mismatch_file
      CSV.read(mismatch_file_path)
    end

    def email_vars(record)
      { LEAD_ID:            record[0],
        CUSTOMER_FULL_NAME: record[1],
        CUSTOMER_EMAIL:     record[2],
        CUSTOMER_ADDRESS:   record[3],
        CUSTOMER_PHONE:     record[4] }
    end

    def customer_attrs(record)
      first_name, last_name = record[8].split
      email = record[9]
      address, city, zip = record[10].split(',')
      phone = record[11]
      { first_name: first_name.strip,
        last_name:  last_name.strip,
        email:      email.strip,
        address:    address.strip,
        city:       city.strip,
        zip:        zip.strip,
        phone:      phone.strip }
    end

    # => ["id", "name", "email", "address", "phone", "status", "user_id", "user_email", "sc_name", "sc_lead_email", "sc_lead_address", "sc_lead_phone", "notes"]
    task lead_mismatches: :environment do
      data = mismatch_file
      data.shift

      data.each do |record|
        lead = Lead.find(record[0].to_i)
        attrs = customer_attrs(record)
        vars = email_vars(record).merge(REP_FULL_NAME: lead.user.full_name)
        to = record[7]

        lead.customer.update_attributes!(attrs)
        PromoterMailer
          .lead_mistmatch(to, vars)
          .deliver_later

        puts "updated mismatched lead: #{lead.id}"
        # puts attrs.inspect
        # puts vars.inspect
        # puts to
      end
    end
  end
end
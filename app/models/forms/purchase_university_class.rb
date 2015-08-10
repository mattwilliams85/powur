module Forms
  class PurchaseUniversityClass
    include ActiveModel::Validations

    attr_accessor :amount, :number, :expiration, :cvv,
                  :firstname, :lastname, :zip, :product_id

    validates :number,
              format:   {
                with:    /\A[0-9]{13,20}\Z/i,
                message: 'Incorrect card number'
              },
              presence: true

    validates_each :expiration do |record, attr, value|
      value = value.to_s
      if value.blank? || !value.match(/\A[0-9]{4}\Z/i)
        record.errors.add(attr, 'Invalid expiration format (MMYY expected)')
      else
        month = value.slice!(0..1)
        exp = (value + month).to_i
        if exp < Time.zone.now.strftime('%y%m').to_i
          record.errors.add(
            attr,
            'Please check the expiration date and try again.')
        end
      end
    end

    validates :cvv,
              format:   {
                with:    /\A[0-9]{3,4}\Z/i,
                message: 'Incorrect cvv number'
              },
              presence: true

    validates :firstname, presence: true
    validates :lastname, presence: true

    validates :zip,
              format:   {
                with:    /\A[0-9]{5}\Z/i,
                message: 'Incorrect zip code'
              },
              presence: true

    validates :amount,
              format:   {
                with:    /\A[0-9]+\Z/i,
                message: 'Incorrect amount'
              },
              presence: true

    validates :product_id, presence: true

    def initialize(opts)
      opts ||= {}
      opts.each do |k, v|
        send("#{k}=", v)
      end
    end

    def as_json(_attrs = {})
      {
        amount:        amount,
        number:        number,
        security_code: cvv,
        exp_date:      expiration,
        product_id:    product_id,
        firstname:     firstname,
        lastname:      lastname,
        zip:           zip
      }
    end
  end
end

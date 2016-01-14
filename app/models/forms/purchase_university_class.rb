module Forms
  class PurchaseUniversityClass
    include ActiveModel::Validations

    attr_accessor :amount, :number, :expiration, :cvv,
                  :firstname, :lastname, :zip, :email,
                  :product_id

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
        month = value[0..1]
        year = value[2..3]
        exp = (year + month).to_i
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
              length: {
                maximum: 10,
                message: 'Incorrect zip code'
              },
              if:     'zip.present?'

    validates :amount,
              numericality: {
                greater_than: 0,
                message:      'Incorrect amount'
              },
              presence:     true

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
        email:         email,
        zip:           zip
      }
    end
  end
end

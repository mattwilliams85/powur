module Forms
  class PurchaseUniversityClass
    include ActiveModel::Validations

    attr_accessor :amount, :number, :expiration, :cvv, :name, :zip, :product_id

    validates :number,
              format: {
                with: /\A[0-9]{13,20}\Z/i,
                message: 'Incorrect card number'
              },
              presence: true

    validates :expiration,
              format: {
                with: /\A[0-9]{4}\Z/i,
                message: 'Incorrect expiration'
              },
              presence: true

    validates :cvv,
              format: {
                with: /\A[0-9]{3,4}\Z/i,
                message: 'Incorrect cvv number'
              },
              presence: true

    validates :name, presence: true

    validates :zip,
              format: {
                with: /\A[0-9]{5}\Z/i,
                message: 'Incorrect zip code'
              },
              presence: true

    validates :amount,
              format: {
                with: /\A[0-9]+\Z/i,
                message: 'Incorrect amount'
              },
              presence: true

    validates :product_id, presence: true

    def initialize(opts)
      opts ||= {}
      opts.each do |k,v|
        send("#{k}=", v)
      end
    end

    def as_json attrs={}
      {
        amount:        amount,
        number:        number,
        security_code: cvv,
        exp_date:      expiration,
        product_id:    product_id,
        firstname:     name.split(' ')[0],
        lastname:      name.split(' ')[1],
        zip:           zip
      }
    end
  end
end

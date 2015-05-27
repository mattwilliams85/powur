namespace :powur do
  namespace :seed do

    CREDS = {
      'production.solarcity.com' =>
        'e250476b639e118cdf712178d38ee6b3058de1368acfd5c54d809fb090faf8de6043e9777b496cdaa1100c16b8a364a2f470398bb50226f88cd80a12f1a382a4'
    }

    task api_clients: :environment do
      ApiClient.destroy_all

      CREDS.each do |client_id, secret|
        ApiClient.create!(id: client_id, secret: secret)
      end
    end

  end
end

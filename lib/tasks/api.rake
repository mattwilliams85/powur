namespace :powur do
  namespace :api do
    task :add_client, [ :client_id ] => :environment do |_t, args|
      attrs = {
        id:     args[:client_id] || SecureRandom.hex(8),
        secret: args[:client_secret] || SecureRandom.hex(32) }
      client = ApiClient.create!(attrs)

      puts "Successfully created app: #{client.id}"
    end

    task :generate_app_token, [ :client_id, :expires_at ] => :environment do |_t, args|
      fail 'missing client_id argument' unless args[:client_id]

      client = ApiClient.find(args[:client_id])
      fail "client not found for id: #{args[:client_id]}" unless client

      attrs = {
        client_id:  client.id,
        expires_at: args[:expires_at] && Time.at(args[:expires_at].to_i).to_datetime }
      token = ApiToken.create!(attrs)

      puts "Generated app token for client #{client.id} with value of #{token.access_token}"
    end
  end
end

#
# NMI runy implementation example:
# https://secure.nmi.com/merchants/resources/integration/integration_portal.php?tid=7c6a58ba471acda5f2fcf3aaf32c257f#dp_ruby
#
class NmiGateway
  attr_reader :params, :login

  def initialize params
    @login = {
      username: ENV['NMI_USERNAME'],
      password: ENV['NMI_PASSWORD'] }
    @params = params
  end

  def billing_query_params
    query = '?'

    query += "&username=#{URI.escape(login[:username])}"
    query += "&password=#{URI.escape(login[:password])}"
    query += "&type=sale"
    query += "&ccnumber=#{params[:number]}"
    query += "&ccexp=#{params[:exp_date]}"
    query += "&amount=#{URI.escape("%.2f" %params[:amount])}"
    query += "&cvv=#{params[:security_code]}"

    query += '&firstname=' + URI.escape(params[:firstname])
    query += '&lastname=' + URI.escape(params[:lastname])
    query += '&zip=' + params[:zip].to_s
  end

  def do_post
    url = 'https://secure.nmi.com'
    conn = Faraday.new(url: url) do |faraday|
      faraday.request :url_encoded             # form-encode POST params
      faraday.adapter Faraday.default_adapter  # make requests with Net::https
    end
    # response = conn.post '/api/transact.php', post_body
    response = conn.post("/api/transact.php/#{billing_query_params}")

    CGI.parse(response.body)
  end
end

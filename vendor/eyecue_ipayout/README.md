  # EyecueIpayout

This gem serves as a wrapper for the iPayout eWallet Web Service.

iPayout hosts some fairly recent documentation for their API.

https://www.i-payout.com/API/default.aspx


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eyecue_ipayout'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install eyecue_ipayout
```

## Configuration

There are a few important constants that you will need to set
as environment variables.  When you do that, make sure you set
them based on the Rails environment that is
running (eg. production, development...)

    #this example is set to use their testing sandbox
    EyecueIpayout.endpoint = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
    EyecueIpayout.merchant_guid = <YOUR MERCHANT GUID>
    EyecueIpayout.merchant_password = <YOUR MERCHANT PASSWORD>

## Development

If you are developing this gem on your local machine, here's a
decent workflow that handles building and updating the gem. Some
code changes don't necessarily need a rebuild.  Changes to the gemspec
certainly warrant a rebuild.

If the gem is already there, remove it:

	```ruby
	rm eyecue_ipayout-0.0.1.gem
	```

Build the gem from your project root:

	```ruby
	gem build eyecue_ipayout.gemspec
	```
Install the gem using it's local path:

	```ruby
	gem install --local eyecue_ipayout-0.0.1.gem
	```

## Usage

Here's how you can use this gem to interact with the iPayout eWallet API.

This gem targets the main service that accepts and returns JSON. iPayout provides endpoints that accept and return different formats (like XML).  However, the JSON endpoint represents is their most recent service an

### the Client
The Client is the higher-level object that speaks to the iPayout eWallet API. It also provides the Service objects.

```ruby
  require 'eyecue_ipayout'

  client = EyecueIpayout.new
  options_hash = {}
  options_hash[:fn] = 'eWallet_GetCustomerDetails'
  options_hash[:endpoint] = IPAYOUT_API_ENDPOINT
  options_hash[:MerchantGUID] = IPAYOUT_MERCHANT_GUID
  options_hash[:MerchantPassword] = EyecueIpayout.merchant_password
  options_hash[:UserName] = 'Glen Danzig'

  service_name = "get_customer_details"
  service = client.get_service(service_name)
```

### the Service
The Service object is instantiated to handle specific calls to the iPayout API.  We can tell the service object what endpoint to hit, and which parameters to send with that request.  What's more, the service object can also return all the parameters that a service will accept.

```ruby
  require 'eyecue_ipayout'

  client = EyecueIpayout.new
  service_name = "eWallet_GetCustomerDetails"
  service = client.get_service(service_name)

  #what params do I need to send for this API call?
  expected_params = service.request_param_list

  # populate that param list as you see fit.
  # in this example, we're using a hypothetical method called
  # populate_service_values
  populated_parameters = populate_service_values(expected_params)

  # All the values are assigned.  Send that out to the eWallet API
  # Hold on....What service is this calling?
  # Remember, the service that you want to call is specified using the
  # "fn" parameter.
  response = client.ewallet_request(populated_parameters)
```
Here's the guts of that JSON request (to the test server, in this example):

{'fn':'eWallet_GetCustomerDetails','endpoint':'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx','MerchantGUID':'a4739056-x3985-xxxx-xxxx-xxxxxxxxx','MerchantPassword':'xXxxXxxXx','UserName':'SomeUserName'}

### Which services can I hit?

#### Register a new user with iPayout
client.ewallet_request('register_user')

#### Get an iPayout user's account details
client.ewallet_request('get_customer_details')

#### See if their account is active
client.ewallet_request('get_user_account_status')

#### Distribute money to an iPayout user
client.ewallet_request('ewallet_load')

## The Response

When you call an iPayout service through the client, you can expect a hash in return, regardless of success or exception.

Responses differ per service request.  There are, however, a couple of consistant parameters that you can reliably reference.

  m_code : That's the numerical response status for your request.  200 means it processed just fine.  500 means there was a server error.

  m_text: This is the human readable message that reports your request's result status.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/eyecue_ipayout/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request





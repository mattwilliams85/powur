# EyecueIpayout

This gem serves as a wrapper for the iPayout eWallet Web Service.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eyecue_ipayout'
```

And then execute:

    $ bundle

Or install it yourself as:

$ gem install eyecue_ipayout

## Configuration

There are a few important constants that you will need to set
as environment variables.  When you do that, make sure you set
them based on the Rails environment that is
running (eg. production, development...)

    ENV['IPAYOUT_API_ENDPOINT'] = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
    ENV['IPAYOUT_MERCHANT_GUID'] = <YOUR MERCHANT GUID>
    ENV['IPAYOUT_MERCHANT_PASSWORD'] = <YOUR MERCHANT PASSWORD>

## Developmet

If you are actively developing this on your local machine, here's a
decent little workflow that handles building and updating the gem.
You can play around with when this actually needs to be done.  Some 
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

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/eyecue_ipayout/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request




## Setting up Postgres

Follow the instuctions here:

https://devcenter.heroku.com/articles/heroku-postgresql#local-setup

## Resetting the DB

```bash
rake db:drop db:create db:migrate
```

## Seed the DB with admin users

Do not simply append this task to the above command, as there is a current rails bug with postgres that makes it fail

```bash
rake db:seed
```

## Seed the DB with the default Products, Bonus Plan, Ranks and Qualifications

The database must not have any Quotes or Orders in order for this to work.

```bash
rake sunstand:seed:bonus_plan
```

Two products are created. One Solar Item product as well as the Consultant Certification product.

## Create quote field lookup values for rate schedule, roof ages, roof types and utility companies

This task happens as part of the task to create the bonus_plan, but you can use it to update or delete values

```bash
rake sunstand:import:quote_field_lookups
```

# Simulation

## Simulate User Genealogy

```bash
rake sunstand:simulate:users
```

There are options that can be used on this command in the form

```bash
rake sunstand:simulate:users[1000,20,3]
```

The first argument is the approximate total # of users. The second is the max # of users in one users particular downline. The third argument is the max of levels to generate for the root users' downline. Note that there must be no spaces in the list of arguments between the brackets. The arguments in the example are the defaults.

## Simulate Orders

```bash
rake sunstand:simulate:orders
```

Arguments can be used for this command as well

```bash
rake sunstand:simulate:orders[20,4]
```

The first argument is the average # of orders per user. A random amount is selected between 0 and twice the #. Orders are generated for approximately 85% of the users for the Solar Item product. One order is created for approximately 75% of the users for the Consultant Certification product. The second argument is how many months back in which to generate orders. A random date is selected between the first of that month and now. The amounts in the example are the defaults.

## 3rd Party (Mobile) API

The API uses the OAuth 2 protocol for access: http://tools.ietf.org/html/rfc6749

### iPhone Credentials

The current iPhone client credentials are:
  id: 'ios.sunstand.com'
  secret: 'ecef509dcfe10f9920469d0b99dd853ff2a2021122ea41e98ae2c64050643f20462cba8e56ae7ecd4bd2915d56720871907e33b191db11a0d4603c33892a'

### Token Endpoint

The token endpoint is at:
  {host}/api/token

In order to get a token, the grant type used is the "Resource Owner Password Credentials Grant": http://tools.ietf.org/html/rfc6749#section-4.3

Include the following parameters to a POST request to the token:

grant_type: 'password'
username: The user's email address
password: The user's password

Optionally, a parameter `expires_in` may be used with the # of seconds in which the token will expire. This is for testing purposes to create a token that will expire shortly or immediately (by including a negative number). By default, a token expires in 1 day.

A token response will include:

access_token: The token value to use in API resource requests
token_type: 'Bearer'
expires_in: The # of seconds in which the token will expire
refresh_token: The token value to use in order to refresh an expired token or a token soon to expire
user_uri: The url to the user as represented by the token

In order to refresh a token, make a POST request to the token endpoint:

grant_type: 'refresh_token'
refresh_token: The refresh token value

The response will be the same token response with a new access_token and refresh_token



[![Circle CI](https://circleci.com/gh/eyecuelab/sunstand.png?style=badge&circle-token=184c29660ce8e18b159cdf7b7a4dd36222abc97a)](https://circleci.com/gh/eyecuelab/sunstand)

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
```
id: ios.sunstand.com
secret: ecef509dcfe10f9920469d0b99dd853ff2a2021122ea41e98ae2c64050643f20462cba8e56ae7ecd4bd2915d56720871907e33b191db11a0d4603c33892a
```

### API Fundamentals

#### Token Endpoint

The token endpoint is at:
  {host}/api/token

In order to get a token, the grant type used is the "Resource Owner Password Credentials Grant": http://tools.ietf.org/html/rfc6749#section-4.3

When making a request for a token, the client application must also authenticate itself with the API. It does this by including the a Basic Authorization header with the client application credentials:
```
Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
```

Include the following parameters to a POST request to the token:
```
grant_type: 'password'
username: The user's email address
password: The user's password
v: The API version the client is using
```

Optionally, a parameter `expires_in` may be used with the # of seconds in which the token will expire. This is for testing purposes to create a token that will expire shortly or immediately (by including a negative number). By default, a token expires in 1 day.

A token response will include:
```
access_token: The token value to use in API resource requests
token_type: 'Bearer'
expires_in: The # of seconds in which the token will expire
refresh_token: The token value to use in order to refresh an expired token or a token soon to expire
session: The url to use to request the user session
api_versions: An array of API versions currently supported on the server.
```

```json
{
  "access_token": "82601bace46850ae901a2d8d8241e0c94c8f58d97d6904c14a5e40679b9677d462e8b62f8ce4bb5a731e617812826a996c2f88a79f8464180ba2f074119f9829",
  "token_type": "Bearer",
  "expires_in": -864000,
  "refresh_token": "09f5c09d112b4aefdfd293975d4f5dd11b53f52d9d11d19a8a8e5d047d82bf8f82031140fba89bb8f2daac7b22f0699ce0724961d7de8d9355ace0c43d972814",
  "session": "/api/session"
}
```
If present, the `v` parameter in the request will change the session URL to include the api version. I.E. `v=1` -> `/api/v1/session`.

#### Refreshing a Token

In order to refresh a token, make a POST request to the token endpoint:
```
grant_type: 'refresh_token'
refresh_token: The refresh token value
v: The API version the client is using
```
The response will be the same token response with a new access_token and refresh_token.

#### Requesting a Resource

When making a request for an API resource, The Authentication header needs to be included with the value of the access_token in the following format:
```
Authorization: Bearer 82601bace46850ae901a2d8d8241e0c94c8f58d97d6904c14a5e40679b9677d462e8b62f8ce4bb5a731e617812826a996c2f88a79f8464180ba2f074119f9829
```

#### Api Errors

Api Errors will be in the format:
```json
{
  "error": "error_code",
  "error_description": "description of error"
}
```

All runtime errors will have a status code of 400, except the error returned when verification of the application credentials fail, which returns a 401. However, this should only happen during development. Certain error_code values should be looked for in the code and handled appropriately.

When making a request for a token with `grant_type=password`, if the credentials are incorrect the following error is returned:
```
{
  "error": "invalid_grant",
  "error_description": "invalid username and/or password"
}
```

When making a request for an API resource, if the access_token is expired, the following error is returned:
```
{
  "error": "invalid_grant",
  "error_description": "access_token is expired"
}
```
The client application should then use the refresh_token to obtain a new set of tokens.

When making a request for a token with `grant_type=refresh_token`, if the refresh_token is no longer valid (user deleted, etc)
```
{
  "error": "invalid_grant",
  "error_description": "invalid refresh_token"
}
```
The user should be logged out of the application in this case and the token data should be deleted.

When making a request for an API resource, if the access_token is invalid for some reason (user deleted, etc), the following error is returned:
```
{
  "error": "invalid_token",
  "error_description": "access_token is invalid"
}
```
The user should be logged out of the application in this case and the token data should be deleted.

[![Circle CI](https://circleci.com/gh/eyecuelab/powur.svg?style=svg&circle-token=184c29660ce8e18b159cdf7b7a4dd36222abc97a)](https://circleci.com/gh/eyecuelab/powur)

## Setting up Postgres

Follow the instuctions here:

https://devcenter.heroku.com/articles/heroku-postgresql#local-setup

## Resetting the DB

```bash
rake db:drop db:create db:migrate
```

## Seeding your DB (not to be done in production)

```bash
rake powur:seed:products
rake powur:seed:zip_codes
rake powur:seed:library
rake powur:seed:advocates
rake powur:seed:leads
rake powur:seed:submitted_leads
rake powur:import:lead_updates DATA_API_ENV=production
```



## Below Deprecated For Now

## 3rd Party (Mobile) API

The API uses the OAuth 2 protocol for access: http://tools.ietf.org/html/rfc6749

### iPhone Credentials

The current iPhone client credentials are:
```
id: ios.powur.com
secret: ecef509dcfe10f9920469d0b99dd853ff2a2021122ea41e98ae2c64050643f20462cba8e56ae7ecd4bd2915d56720871907e33b191db11a0d4603c33892a
```

### API Fundamentals

The API security conforms to the popular OAuth2 protocol. http://tools.ietf.org/html/rfc6749#section-11.4

#### Root Resource

The root resource is used to determine the API entry points for the application as well retrieve the meta-data for the forgot password functionality. Include the `v` parameter with the server API version you are targeting so that the subsequent URLs will be versioned according to the version the client is using. This should be the only URL path that the client app needs to hard code. The API responses will include all the meta-data necessary to construct requests for API resources.

GET {host}/api?v=1

```json
{
  "class": [
    "api"
  ],
  "actions": [
    {
      "name": "password",
      "method": "POST",
      "href": "/api/password",
      "type": "application/json",
      "fields": [
        {
          "name": "email",
          "type": "email",
          "required": true
        }
      ]
    },
    {
      "name": "token",
      "method": "POST",
      "href": "/api/v1/token",
      "type": "application/json",
      "fields": [
        {
          "name": "grant_type",
          "type": "text",
          "value": "password",
          "required": true
        },
        {
          "name": "username",
          "type": "email",
          "required": true
        },
        {
          "name": "password",
          "type": "password",
          "required": true
        }
      ]
    },
    {
      "name": "refresh_token",
      "method": "POST",
      "href": "/api/v1/token",
      "type": "application/json",
      "fields": [
        {
          "name": "grant_type",
          "type": "text",
          "value": "refresh_token",
          "required": true
        },
        {
          "name": "refresh_token",
          "type": "text",
          "required": true
        }
      ]
    }
  ],
  "links": [
    {
      "rel": "self",
      "href": "/api"
    }
  ]
}
```

#### Token Endpoint

In order to obtain an authorization token, the grant type used is the "Resource Owner Password Credentials Grant": http://tools.ietf.org/html/rfc6749#section-4.3

When making a request for a token, the client application must also authenticate itself with the API. It does this by including the a Basic Authorization header with the client application credentials:
```
Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
```

Include the following parameters to a POST request to the token:
```
grant_type: 'password'
username: The user's email address
password: The user's password
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
  "expires_in": 3600,
  "refresh_token": "09f5c09d112b4aefdfd293975d4f5dd11b53f52d9d11d19a8a8e5d047d82bf8f82031140fba89bb8f2daac7b22f0699ce0724961d7de8d9355ace0c43d972814",
  "session": "/api/v1/session"
}
```

#### Refreshing a Token

In order to refresh a token, make a POST request to the token endpoint:
```
grant_type: 'refresh_token'
refresh_token: The refresh token value
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

#### Api Workflow in CURL

api root
```bash
curl -u "ios.powur.com:ecef509dcfe10f9920469d0b99dd853ff2a2021122ea41e98ae2c64050643f20462cba8e56ae7ecd4bd2915d56720871907e33b191db11a0d4603c33892a" -X POST -d "grant_type=password&username=jon@powur.com&password=solarpower" "http://sandbox.eyecuelab.com/api/v1/token"
```
response: https://gist.github.com/paulwalker/bf0ff2c05b50a0bcc97f

token
```bash
curl -u "ios.powur.com:ecef509dcfe10f9920469d0b99dd853ff2a2021122ea41e98ae2c64050643f20462cba8e56ae7ecd4bd2915d56720871907e33b191db11a0d4603c33892a" -X POST -d "grant_type=password&username=jon@powur.com&password=solarpower" "http://sandbox.eyecuelab.com/api/v1/token"
```
response: https://gist.github.com/paulwalker/5898adbd4a0d5978c375

take the access_token from the response you get and use as the parameter in subsequent requests

session
```bash
curl "http://sandbox.eyecuelab.com/api/v1/session?access_token=accd89aa0a2b2b55789df28f98ba82b63a1dab38188db488cb45853d73a144289c5f7e14feadf5f580c4b685b921fc2f5caecbe14a82ecc38b27342bd32f4796"
```
response: https://gist.github.com/paulwalker/302bd4cfe9d76a5bce8a

users
```bash
curl "http://sandbox.eyecuelab.com/api/v1/users?access_token=accd89aa0a2b2b55789df28f98ba82b63a1dab38188db488cb45853d73a144289c5f7e14feadf5f580c4b685b921fc2f5caecbe14a82ecc38b27342bd32f4796"
```

# Heroku Deployment

## Staging
sunstand-staging.eyecuelab.com

The staging server is updated whenever anyone executes a succcessful push to the 'develop' branch.



## Production
sunstand-staging.eyecuelab.com

Set up your remote in your project's .git/config file

```bash
[remote "production"]
  url = git@heroku.com:sunstand.git
```

The staging server is updated whenever anyone executes a succcessful push to the 'develop' branch.

This is a pretty typical workflow if you ever have need to deploy development changes to production.

```bash
git branch #starting on branch develop
git checkout master
git pull origin master
git merge develop
bundle install
rake db:migrate
rake spec
git push production master
```
As you can see, we are pushing to 'production master' as opposed to 'origin master'


### Production tasks

You don't have to run these every time. Typically, you do when you have changes to seed data
or some heavy-duty database changes.

It's important to specify 'sunstand' for the --confirm and --app tag.  Otherwise, this will
run on staging.


```bash
# reset the database
heroku pg:reset HEROKU_POSTGRESQL_AMBER_URL --confirm powur

# migrate the data
heroku run rake db:migrate --app powur

# add the admin users
heroku run rake db:seed --app powur

# populate the bonus_plans, geaneology, and orders
heroku run rake sunstand:seed:bonus_plan sunstand:simulate:users sunstand:simulate:orders --app sunstand
```
